import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/data/business_providers.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/core/network/api_providers.dart';
import 'package:vendeai_mobile/features/auth/application/auth_controller.dart';
import 'package:vendeai_mobile/features/auth/data/auth_repository.dart';
import 'api_session_test.dart' show MemoryStorage, TestAdapter, body;
import 'session_switch_test.dart' show loginBody;

void main() {
  test(
    'all business providers discard A on logout and fetch only B after login',
    () async {
      final storage = MemoryStorage()
        ..access = null
        ..refresh = null;
      final remote = Dio()
        ..httpClientAdapter = TestAdapter((_) => body('{}', 200));
      final api = ApiClient(storage: storage, refreshClient: remote);
      final requests = <String>[];
      api.dio.httpClientAdapter = TestAdapter((r) {
        if (r.path == '/auth/login') {
          return loginBody((r.data['email'] as String).split('@').first);
        }
        final user = r.headers['Authorization'] == 'Bearer a-access'
            ? 'a'
            : 'b';
        requests.add('$user:${r.path}');
        if (r.path == '/finance/summary') {
          return body(
            jsonEncode({
              'data': {'userId': user},
            }),
            200,
          );
        }
        return body(
          jsonEncode({
            'data': {
              'items': [
                {'id': 'record-$user', 'userId': user},
              ],
            },
          }),
          200,
        );
      });
      final container = ProviderContainer(
        overrides: [apiClientProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      await controller.login('a@example.com', 'test');
      final lists = [
        clientsProvider,
        quotesProvider,
        contractsProvider,
        financeEntriesProvider,
        categoriesProvider,
      ];
      final subscriptions = lists
          .map((p) => container.listen(p, (_, _) {}))
          .toList();
      final dashboard = container.listen(dashboardProvider, (_, _) {});
      addTearDown(() {
        for (final s in subscriptions) {
          s.close();
        }
        dashboard.close();
      });
      for (final p in lists) {
        expect((await container.read(p.future)).single['userId'], 'a');
      }
      expect((await container.read(dashboardProvider.future))['userId'], 'a');
      await controller.logout();
      for (final p in lists) {
        expect(await container.read(p.future), isEmpty);
      }
      expect(await container.read(dashboardProvider.future), isEmpty);
      expect(requests, hasLength(6));
      await controller.login('b@example.com', 'test');
      for (final p in lists) {
        expect((await container.read(p.future)).single['userId'], 'b');
      }
      expect((await container.read(dashboardProvider.future))['userId'], 'b');
      expect(requests.where((r) => r.startsWith('b:')), hasLength(6));
    },
  );

  test(
    'an in-flight A list cannot replace the B list even when it arrives last',
    () async {
      final storage = MemoryStorage()
        ..access = null
        ..refresh = null;
      final api = ApiClient(storage: storage);
      final started = Completer<void>();
      final oldResponse = Completer<ResponseBody>();
      api.dio.httpClientAdapter = TestAdapter((r) {
        if (r.path == '/auth/login') {
          return loginBody((r.data['email'] as String).split('@').first);
        }
        if (r.headers['Authorization'] == 'Bearer a-access') {
          started.complete();
          return oldResponse.future;
        }
        return body('{"data":{"items":[]}}', 200);
      });
      final container = ProviderContainer(
        overrides: [apiClientProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      await controller.login('a@example.com', 'test');
      final subscription = container.listen(clientsProvider, (_, _) {});
      addTearDown(subscription.close);
      await started.future;
      await controller.login('b@example.com', 'test');
      expect(await container.read(clientsProvider.future), isEmpty);
      oldResponse.complete(body('{"data":{"items":[{"userId":"a"}]}}', 200));
      await Future<void>.delayed(Duration.zero);
      expect(await container.read(clientsProvider.future), isEmpty);
      expect(container.read(authControllerProvider).valueOrNull?.id, 'b');
    },
  );

  test(
    'restoration from A cannot change controller state after B logs in',
    () async {
      final storage = MemoryStorage();
      final api = ApiClient(storage: storage);
      final started = Completer<void>();
      final oldResponse = Completer<ResponseBody>();
      api.dio.httpClientAdapter = TestAdapter((r) {
        if (r.path == '/auth/login') return loginBody('b');
        started.complete();
        return oldResponse.future;
      });
      final controller = AuthController(AuthRepository(api));
      addTearDown(controller.dispose);
      final restoring = controller.restore();
      await started.future;
      await controller.login('b@example.com', 'test');
      oldResponse.complete(
        body(
          '{"data":{"id":"a","email":"a@example.com","profile":{"fullName":"A"}}}',
          200,
        ),
      );
      await restoring;
      expect(controller.state.valueOrNull?.id, 'b');
      expect(storage.access, 'b-access');
    },
  );
}
