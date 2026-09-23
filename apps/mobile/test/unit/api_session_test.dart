import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/core/storage/secure_storage_service.dart';

class MemoryStorage extends SecureStorageService {
  String? access = 'old-access';
  String? refresh = 'old-refresh';
  bool failClear = false;
  int clears = 0;
  @override
  Future<String?> getAccessToken() async => access;
  @override
  Future<String?> getRefreshToken() async => refresh;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clearAll() async {
    clears++;
    if (failClear) throw StateError('Storage unavailable');
    access = null;
    refresh = null;
  }
}

class TestAdapter implements HttpClientAdapter {
  TestAdapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody body(String json, int status) => ResponseBody.fromString(
  json,
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

void main() {
  test(
    'parallel unauthorized requests share one refresh and retry with new token',
    () async {
      final storage = MemoryStorage();
      final refreshStarted = Completer<void>();
      final refreshResult = Completer<ResponseBody>();
      var refreshCalls = 0;
      final refresh = Dio()
        ..httpClientAdapter = TestAdapter((_) {
          refreshCalls++;
          if (!refreshStarted.isCompleted) refreshStarted.complete();
          return refreshResult.future;
        });
      final api = ApiClient(storage: storage, refreshClient: refresh);
      var expired = 0;
      api.onSessionExpired = () => expired++;
      var oldRequests = 0;
      final bothUnauthorized = Completer<void>();
      api.dio.httpClientAdapter = TestAdapter((options) {
        if (options.headers['Authorization'] == 'Bearer new-access') {
          return body('{"ok":true}', 200);
        }
        oldRequests++;
        if (oldRequests == 2) bothUnauthorized.complete();
        return body('{}', 401);
      });
      final first = api.dio.get('/clients');
      final second = api.dio.get('/quotes');
      await bothUnauthorized.future;
      await refreshStarted.future;
      await Future<void>.delayed(Duration.zero);
      refreshResult.complete(
        body(
          '{"data":{"accessToken":"new-access","refreshToken":"new-refresh"}}',
          200,
        ),
      );
      final responses = await Future.wait([first, second]);
      expect(responses.every((r) => r.statusCode == 200), isTrue);
      expect(refreshCalls, 1);
      expect(expired, 0);
      expect(storage.refresh, 'new-refresh');
    },
  );

  for (final scenario in [
    'missing token',
    'invalid response',
    'server rejects',
    'storage failure',
  ]) {
    test('refresh failure expires session: $scenario', () async {
      final storage = MemoryStorage();
      if (scenario == 'missing token') storage.refresh = null;
      storage.failClear = scenario == 'storage failure';
      var calls = 0;
      final refresh = Dio()
        ..httpClientAdapter = TestAdapter((_) {
          calls++;
          return body('{}', scenario == 'invalid response' ? 200 : 401);
        });
      final api = ApiClient(storage: storage, refreshClient: refresh);
      api.dio.httpClientAdapter = TestAdapter((_) => body('{}', 401));
      var expired = 0;
      api.onSessionExpired = () => expired++;
      await expectLater(
        api.dio.get('/clients').timeout(const Duration(seconds: 2)),
        throwsA(isA<DioException>()),
      );
      expect(expired, 1);
      expect(storage.clears, 1);
      expect(calls, scenario == 'missing token' ? 0 : 1);
    });
  }
  test(
    'invalid login never triggers token refresh or session expiration',
    () async {
      final storage = MemoryStorage();
      var calls = 0;
      final refresh = Dio()
        ..httpClientAdapter = TestAdapter((_) {
          calls++;
          return body('{}', 401);
        });
      final api = ApiClient(storage: storage, refreshClient: refresh);
      api.dio.httpClientAdapter = TestAdapter((_) => body('{}', 401));
      var expired = 0;
      api.onSessionExpired = () => expired++;
      await expectLater(
        api.dio.post('/auth/login'),
        throwsA(isA<DioException>()),
      );
      expect(calls, 0);
      expect(expired, 0);
      expect(storage.clears, 0);
    },
  );
}
