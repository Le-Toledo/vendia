import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/core/network/api_providers.dart';
import 'package:vendeai_mobile/features/chat_ai/presentation/chat_ai_screen.dart';
import 'unit/api_session_test.dart' show MemoryStorage, TestAdapter, body;

void main() {
  for (final leaveScreen in [false, true]) {
    testWidgets(
      'chat prevents duplicate requests and handles completion (leave=$leaveScreen)',
      (tester) async {
        final result = Completer<ResponseBody>();
        var requests = 0;
        final api = ApiClient(storage: MemoryStorage());
        api.dio.httpClientAdapter = TestAdapter((options) {
          if (options.path == '/app/config') {
            return body(
              '{"data":{"ai":{"id":"mock","name":"Teste","consentVersion":"v1"}}}',
              200,
            );
          }
          if (options.path == '/users/me') {
            return body(
              '{"data":{"settings":{"aiConsentVersion":"v1","aiConsentProvider":"mock","aiConsentAt":"2026-09-22"}}}',
              200,
            );
          }
          requests++;
          return result.future;
        });
        await tester.pumpWidget(
          ProviderScope(
            overrides: [apiClientProvider.overrideWithValue(api)],
            child: const MaterialApp(home: ChatAiScreen()),
          ),
        );
        await tester.enterText(find.byType(TextField), 'Primeira mensagem');
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'Segunda mensagem');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        expect(requests, 1);
        if (leaveScreen) {
          await tester.pumpWidget(const SizedBox());
          result.complete(body('{}', 500));
        } else {
          result.complete(
            body('{"data":{"content":"Resposta de teste"}}', 200),
          );
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (!leaveScreen) {
          expect(find.text('Resposta de teste'), findsOneWidget);
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            'Segunda mensagem',
          );
        }
      },
    );
  }
}
