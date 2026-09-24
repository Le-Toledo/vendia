import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/core/network/network_diagnostics.dart';
import 'package:vendeai_mobile/core/data/business_repository.dart';
import 'package:vendeai_mobile/features/auth/data/auth_repository.dart';
import 'api_session_test.dart';
import 'session_switch_test.dart' show loginBody;

class PendingLoginStorage extends MemoryStorage {
  final started = Completer<void>();
  final finish = Completer<void>();
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    started.complete();
    await finish.future;
    await super.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

void main() {
  test(
    'diagnostics redact credentials, identifiers, bodies and error messages',
    () {
      final lines = <String>[];
      final diagnostics = NetworkDiagnostics(enabled: true, sink: lines.add);
      final options = RequestOptions(
        path:
            'https://secret-user:secret-pass@example.com/api/v1/clients/private-id?token=secret-query',
        method: 'POST',
        headers: {'Authorization': 'Bearer secret-access'},
        data: {'refreshToken': 'secret-refresh', 'name': 'private-name'},
      );
      diagnostics.record(
        'error',
        options,
        status: 401,
        error: DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          error: StateError('secret-error'),
        ),
      );
      final line = lines.single;
      for (final secret in [
        'secret-user',
        'secret-pass',
        'secret-query',
        'secret-access',
        'secret-refresh',
        'private-id',
        'private-name',
        'secret-error',
      ]) {
        expect(line, isNot(contains(secret)));
      }
      expect(line, contains('"status":401'));
      expect(line, contains('"accessTokenPresent":true'));
      expect(line, contains('"dioType":"badResponse"'));
    },
  );

  test('diagnostics are silent by default and tolerate a failing sink', () {
    final lines = <String>[];
    final request = RequestOptions(path: '/clients');
    NetworkDiagnostics(sink: lines.add).record('send', request);
    expect(lines, isEmpty);
    expect(
      () => NetworkDiagnostics(
        enabled: true,
        sink: (_) => throw StateError('sink'),
      ).record('send', request),
      returnsNormally,
    );
  });

  test(
    'client POST waits for pending token storage and sends the new bearer',
    () async {
      final storage = PendingLoginStorage();
      final lines = <String>[];
      final api = ApiClient(
        storage: storage,
        diagnostics: NetworkDiagnostics(enabled: true, sink: lines.add),
      );
      var clientCalls = 0;
      api.dio.httpClientAdapter = TestAdapter((request) {
        if (request.path == '/auth/login') return loginBody('b');
        clientCalls++;
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer b-access');
        return body(
          jsonEncode({
            'data': {'id': 'client-b', 'name': 'Example'},
          }),
          201,
        );
      });
      final login = AuthRepository(api).login('b@example.com', 'test');
      await storage.started.future;
      final create = BusinessRepository(
        api,
      ).save('/clients', {'name': 'Example'});
      await Future<void>.delayed(Duration.zero);
      expect(clientCalls, 0);
      storage.finish.complete();
      await login;
      expect((await create)['id'], 'client-b');
      expect(clientCalls, 1);
      expect(lines.any((line) => line.contains('"status":201')), isTrue);
    },
  );
}
