import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_providers.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthUser?>>((ref) {
      final controller = AuthController(ref.watch(authRepositoryProvider));
      ref.read(apiClientProvider).onSessionExpired = controller.expireSession;
      controller.restore();
      return controller;
    });

class AuthController extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthController(this.repository) : super(const AsyncLoading());
  final AuthRepository repository;
  Future<void> restore() async {
    try {
      state = AsyncData(await repository.restore());
    } catch (_) {
      state = const AsyncData(null);
    }
  }

  Future<void> login(String email, String password) =>
      _run(() => repository.login(email, password));
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? company,
  }) => _run(
    () => repository.register(
      name: name,
      email: email,
      password: password,
      company: company,
    ),
  );
  Future<void> loginWithApple() => _run(repository.loginWithApple);
  Future<void> loginWithGoogle() => _run(repository.loginWithGoogle);
  Future<void> logout() async {
    try {
      await repository.logout();
    } finally {
      state = const AsyncData(null);
    }
  }

  void expireSession() => state = const AsyncData(null);
  Future<void> clearLocalSession() async {
    await repository.clearLocalSession();
    state = const AsyncData(null);
  }

  Future<void> deleteAccount() async {
    await repository.deleteAccount();
    state = const AsyncData(null);
  }

  Future<void> _run(Future<AuthUser> Function() action) async {
    state = await AsyncValue.guard(action);
  }
}
