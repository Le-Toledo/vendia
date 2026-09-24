import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/features/auth/data/auth_repository.dart';
import 'package:vendeai_mobile/features/auth/application/auth_controller.dart';
import 'api_session_test.dart' show MemoryStorage, TestAdapter, body;

ResponseBody loginBody(String user) => body(
  jsonEncode({
    'data': {
      'user': {
        'id': user,
        'email': '$user@example.com',
        'profile': {'fullName': user},
      },
      'tokens': {
        'accessToken': '$user-access',
        'refreshToken': '$user-refresh',
      },
    },
  }),
  200,
);

class SlowStorage extends MemoryStorage {
  final writeStarted = Completer<void>();
  final finishWrite = Completer<void>();
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (accessToken == 'refreshed-a') {
      writeStarted.complete();
      await finishWrite.future;
    }
    await super.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

void main() {
  for (final newSession in ['login', 'logout']) {
    for (final status in [200, 401]) {
      test(
        'old refresh $status cannot affect a subsequent $newSession',
        () async {
          final storage = MemoryStorage();
          final started = Completer<void>();
          final result = Completer<ResponseBody>();
          final refresh = Dio()
            ..httpClientAdapter = TestAdapter((request) {
              if (request.path == '/auth/logout') return body('{}', 200);
              started.complete();
              return result.future;
            });
          final api = ApiClient(storage: storage, refreshClient: refresh);
          var expirations = 0;
          api.onSessionExpired = () => expirations++;
          final requests = <RequestOptions>[];
          api.dio.httpClientAdapter = TestAdapter((request) {
            requests.add(request);
            if (request.path == '/auth/login') {
              expect(request.headers.containsKey('Authorization'), isFalse);
              return loginBody('b');
            }
            return body('{}', 401);
          });
          final oldRequest = expectLater(
            api.dio.get('/clients'),
            throwsA(isA<DioException>()),
          );
          await started.future;
          final repository = AuthRepository(api);
          if (newSession == 'login') {
            expect((await repository.login('b@example.com', 'test')).id, 'b');
          } else {
            await repository.logout();
          }
          result.complete(
            body(
              '{"data":{"accessToken":"stale-a","refreshToken":"stale-refresh-a"}}',
              status,
            ),
          );
          await oldRequest;
          expect(storage.access, newSession == 'login' ? 'b-access' : null);
          expect(storage.refresh, newSession == 'login' ? 'b-refresh' : null);
          expect(expirations, 0);
          expect(requests.where((r) => r.path == '/clients'), hasLength(1));
        },
      );
    }
  }

  test(
    'a Keychain write already in progress cannot outlive the new login',
    () async {
      final storage = SlowStorage();
      final refresh = Dio()
        ..httpClientAdapter = TestAdapter(
          (_) => body(
            '{"data":{"accessToken":"refreshed-a","refreshToken":"refresh-a"}}',
            200,
          ),
        );
      final api = ApiClient(storage: storage, refreshClient: refresh);
      api.dio.httpClientAdapter = TestAdapter(
        (r) => r.path == '/auth/login' ? loginBody('b') : body('{}', 401),
      );
      final old = expectLater(
        api.dio.get('/quotes'),
        throwsA(isA<DioException>()),
      );
      await storage.writeStarted.future;
      final login = AuthRepository(api).login('b@example.com', 'test');
      storage.finishWrite.complete();
      await login;
      await old;
      expect(storage.access, 'b-access');
      expect(storage.refresh, 'b-refresh');
    },
  );

  test(
    'late business data and late 401 from A are rejected without refreshing B',
    () async {
      for (final status in [200, 401]) {
        final storage = MemoryStorage();
        final arrived = Completer<void>();
        final response = Completer<ResponseBody>();
        var refreshes = 0;
        final refresh = Dio()
          ..httpClientAdapter = TestAdapter((_) {
            refreshes++;
            return body('{}', 401);
          });
        final api = ApiClient(storage: storage, refreshClient: refresh);
        api.dio.httpClientAdapter = TestAdapter((request) {
          if (request.path == '/auth/login') return loginBody('b');
          arrived.complete();
          return response.future;
        });
        final old = expectLater(
          api.dio.get('/clients'),
          throwsA(
            isA<DioException>().having(
              (e) => e.type,
              'canceled',
              DioExceptionType.cancel,
            ),
          ),
        );
        await arrived.future;
        await AuthRepository(api).login('b@example.com', 'test');
        response.complete(body('{"data":{"items":[{"userId":"a"}]}}', status));
        await old;
        expect(refreshes, 0);
        expect(storage.access, 'b-access');
      }
    },
  );

  test('a late login response cannot replace the newer login', () async {
    final storage = MemoryStorage();
    final first = Completer<ResponseBody>();
    final arrived = Completer<void>();
    final api = ApiClient(storage: storage);
    api.dio.httpClientAdapter = TestAdapter((r) {
      if (r.data['email'] == 'a@example.com') {
        arrived.complete();
        return first.future;
      }
      return loginBody('b');
    });
    final controller = AuthController(AuthRepository(api));
    addTearDown(controller.dispose);
    final old = controller.login('a@example.com', 'test');
    await arrived.future;
    await controller.login('b@example.com', 'test');
    first.complete(loginBody('a'));
    await old;
    expect(storage.access, 'b-access');
    expect(controller.state.valueOrNull?.id, 'b');
  });

  test(
    'failed new login clears old credentials instead of restoring A',
    () async {
      final storage = MemoryStorage();
      final api = ApiClient(storage: storage);
      api.dio.httpClientAdapter = TestAdapter((r) {
        expect(r.headers.containsKey('Authorization'), isFalse);
        return body('{}', 401);
      });
      await expectLater(
        AuthRepository(api).login('b@example.com', 'wrong'),
        throwsA(isA<ApiException>()),
      );
      expect(storage.access, isNull);
      expect(storage.refresh, isNull);
    },
  );

  test('late logout failure cannot clear a newly authenticated B', () async {
    final storage = MemoryStorage();
    final arrived = Completer<void>();
    final response = Completer<ResponseBody>();
    final remote = Dio()
      ..httpClientAdapter = TestAdapter((r) {
        expect(r.path, '/auth/logout');
        expect(r.headers['Authorization'], 'Bearer old-access');
        arrived.complete();
        return response.future;
      });
    final api = ApiClient(storage: storage, refreshClient: remote);
    api.dio.httpClientAdapter = TestAdapter((_) => loginBody('b'));
    final controller = AuthController(AuthRepository(api));
    addTearDown(controller.dispose);
    final logout = expectLater(
      controller.logout(),
      throwsA(isA<DioException>()),
    );
    await arrived.future;
    expect(storage.access, isNull);
    await controller.login('b@example.com', 'test');
    response.complete(body('{}', 500));
    await logout;
    expect(storage.access, 'b-access');
    expect(controller.state.valueOrNull?.id, 'b');
  });

  test('completion of A refresh leaves B refresh coalescing intact', () async {
    final storage = MemoryStorage();
    final aStarted = Completer<void>();
    final bStarted = Completer<void>();
    final aResponse = Completer<ResponseBody>();
    final bResponse = Completer<ResponseBody>();
    final bothBRequests = Completer<void>();
    var bRequests = 0;
    var refreshes = 0;
    final remote = Dio()
      ..httpClientAdapter = TestAdapter((r) {
        refreshes++;
        if (r.data['refreshToken'] == 'old-refresh') {
          aStarted.complete();
          return aResponse.future;
        }
        if (!bStarted.isCompleted) bStarted.complete();
        return bResponse.future;
      });
    final api = ApiClient(storage: storage, refreshClient: remote);
    api.dio.httpClientAdapter = TestAdapter((r) {
      if (r.path == '/auth/login') return loginBody('b');
      if (r.headers['Authorization'] == 'Bearer b-new') return body('{}', 200);
      if (r.headers['Authorization'] == 'Bearer b-access') {
        bRequests++;
        if (bRequests == 2) bothBRequests.complete();
      }
      return body('{}', 401);
    });
    final old = expectLater(
      api.dio.get('/clients'),
      throwsA(isA<DioException>()),
    );
    await aStarted.future;
    await AuthRepository(api).login('b@example.com', 'test');
    final firstB = api.dio.get('/quotes');
    await bStarted.future;
    aResponse.complete(
      body(
        '{"data":{"accessToken":"a-new","refreshToken":"a-new-refresh"}}',
        200,
      ),
    );
    await old;
    final secondB = api.dio.get('/contracts');
    await bothBRequests.future;
    await Future<void>.delayed(Duration.zero);
    bResponse.complete(
      body(
        '{"data":{"accessToken":"b-new","refreshToken":"b-new-refresh"}}',
        200,
      ),
    );
    await Future.wait([firstB, secondB]);
    expect(refreshes, 2);
    expect(storage.access, 'b-new');
  });

  test('logout cancels a login still in flight', () async {
    final storage = MemoryStorage();
    final arrived = Completer<void>();
    final response = Completer<ResponseBody>();
    final api = ApiClient(storage: storage);
    api.dio.httpClientAdapter = TestAdapter((r) {
      arrived.complete();
      return response.future;
    });
    final controller = AuthController(AuthRepository(api));
    addTearDown(controller.dispose);
    final login = controller.login('a@example.com', 'test');
    await arrived.future;
    await controller.logout();
    response.complete(loginBody('a'));
    await login;
    expect(storage.access, isNull);
    expect(controller.state.valueOrNull, isNull);
    expect(controller.state.hasError, isFalse);
  });

  test(
    'late 401 after a successful refresh reuses the new token without another refresh',
    () async {
      final storage = MemoryStorage();
      final late = Completer<ResponseBody>();
      final arrived = Completer<void>();
      var refreshes = 0;
      final refresh = Dio()
        ..httpClientAdapter = TestAdapter((_) {
          refreshes++;
          return body(
            '{"data":{"accessToken":"new-access","refreshToken":"new-refresh"}}',
            200,
          );
        });
      final api = ApiClient(storage: storage, refreshClient: refresh);
      api.dio.httpClientAdapter = TestAdapter((r) {
        if (r.headers['Authorization'] == 'Bearer new-access') {
          return body('{}', 200);
        }
        if (r.path == '/quotes') {
          arrived.complete();
          return late.future;
        }
        return body('{}', 401);
      });
      final second = api.dio.get('/quotes');
      await arrived.future;
      await api.dio.get('/clients');
      late.complete(body('{}', 401));
      await second;
      expect(refreshes, 1);
    },
  );
}
