import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/features/auth/application/auth_controller.dart';
import 'package:vendeai_mobile/features/auth/data/auth_repository.dart';
import 'package:vendeai_mobile/core/storage/secure_storage_service.dart';

class FakeStorage extends SecureStorageService {
  @override
  Future<String?> getAccessToken() async => null;
}

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(ApiClient(storage: FakeStorage()));
  bool loggedOut = false;
  bool failLogout = false;
  final user = const AuthUser(id: '1', email: 'user@example.com', name: 'User');
  @override
  Future<AuthUser> restore() async => user;
  @override
  Future<AuthUser> login(String email, String password) async => user;
  @override
  Future<void> logout() async {
    loggedOut = true;
    if (failLogout) throw Exception('Network unavailable');
  }
}

void main() {
  test(
    'logout clears in-memory session even when the server is unreachable',
    () async {
      final repository = FakeAuthRepository()..failLogout = true;
      final controller = AuthController(repository);
      addTearDown(controller.dispose);
      await controller.restore();
      await expectLater(controller.logout(), throwsException);
      expect(controller.state, const AsyncData<AuthUser?>(null));
    },
  );
  test('controller restores, authenticates and clears session', () async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository);
    await controller.restore();
    expect(controller.state.valueOrNull?.email, 'user@example.com');
    await controller.login('user@example.com', 'password');
    expect(controller.state.hasError, false);
    await controller.logout();
    expect(repository.loggedOut, true);
    expect(controller.state, const AsyncData<AuthUser?>(null));
  });
}
