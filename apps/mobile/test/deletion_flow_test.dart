import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vendeai_mobile/core/data/business_providers.dart';
import 'package:vendeai_mobile/core/data/business_repository.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/core/storage/secure_storage_service.dart';
import 'package:vendeai_mobile/features/clients/presentation/client_form_screen.dart';
import 'package:vendeai_mobile/features/quotes/presentation/quote_detail_screen.dart';

class TestStorage extends SecureStorageService {
  @override
  Future<String?> getAccessToken() async => null;
}

void main() {
  for (final kind in ['cliente', 'orçamento']) {
    for (final outcome in ['cancel', 'success', 'error']) {
      testWidgets('iOS $kind deletion: $outcome with nested navigation', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final requests = <RequestOptions>[];
        final pending = Completer<void>();
        final api = ApiClient(storage: TestStorage());
        const linked =
            'Este cliente não pode ser excluído enquanto possuir orçamentos ou contratos vinculados.';
        api.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              requests.add(options);
              await pending.future;
              if (outcome == 'error') {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response(
                      requestOptions: options,
                      statusCode: kind == 'cliente' ? 409 : 500,
                      data: {
                        'message': kind == 'cliente'
                            ? linked
                            : 'Erro interno no servidor',
                      },
                    ),
                  ),
                );
              } else {
                handler.resolve(
                  Response(requestOptions: options, statusCode: 200),
                );
              }
            },
          ),
        );
        final path = kind == 'cliente' ? '/clients' : '/quotes';
        var loads = 0;
        final provider = kind == 'cliente' ? clientsProvider : quotesProvider;
        final container = ProviderContainer(
          overrides: [
            businessRepositoryProvider.overrideWithValue(
              BusinessRepository(api),
            ),
            provider.overrideWith((ref) async {
              loads++;
              return <Map<String, dynamic>>[];
            }),
          ],
        );
        final subscription = container.listen(provider, (_, _) {});
        await container.read(provider.future);
        final router = GoRouter(
          initialLocation: '$path/detail',
          routes: [
            ShellRoute(
              builder: (_, _, child) => child,
              routes: [
                GoRoute(
                  path: path,
                  builder: (_, _) => Scaffold(body: Text('Lista $kind')),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (_, _) => kind == 'cliente'
                          ? const ClientFormScreen(
                              clientToEdit: {
                                'id': 'record-1',
                                'name': 'Cliente',
                              },
                            )
                          : const QuoteDetailScreen(
                              quote: {
                                'id': 'record-1',
                                'codeNumber': 'ORC-1',
                                'total': '10',
                                'status': 'DRAFT',
                                'items': [],
                              },
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
        addTearDown(() {
          router.dispose();
          subscription.close();
          container.dispose();
          api.dio.close(force: true);
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: ThemeData(platform: TargetPlatform.iOS),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (kind == 'orçamento' && outcome != 'cancel') {
          // Exercise the overflow action as well as its dialog on a root navigator.
          await tester.tap(find.byTooltip('Ações do orçamento'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Excluir orçamento').last);
        } else {
          await tester.tap(find.text('Excluir $kind'));
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Excluir $kind?'), findsOneWidget);
        expect(requests, isEmpty);
        await tester.tap(
          find.text(outcome == 'cancel' ? 'Cancelar' : 'Excluir'),
        );
        await tester.pump();
        if (outcome == 'cancel') {
          await tester.pumpAndSettle();
          expect(requests, isEmpty);
          expect(
            router.routeInformationProvider.value.uri.path,
            '$path/detail',
          );
          return;
        }
        await tester.pump(const Duration(milliseconds: 400));
        expect(requests, hasLength(1));
        expect(requests.single.method, 'DELETE');
        expect(requests.single.path, '$path/record-1');
        final button = kind == 'cliente'
            ? tester.widget<TextButton>(
                find.widgetWithText(TextButton, 'Excluir cliente'),
              )
            : tester.widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Excluir orçamento'),
              );
        expect(button.onPressed, isNull);
        pending.complete();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (outcome == 'success') {
          expect(find.text('Lista $kind'), findsOneWidget);
          expect(loads, 2);
        } else {
          expect(
            router.routeInformationProvider.value.uri.path,
            '$path/detail',
          );
          expect(
            find.text(
              kind == 'cliente'
                  ? linked
                  : 'Não foi possível excluir o orçamento. Tente novamente em instantes.',
            ),
            findsOneWidget,
          );
          expect(loads, 1);
        }
      });
    }
  }
}
