import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_providers.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthUser?>>((ref) {
      final controller = AuthController(ref.watch(authRepositoryProvider));
      final api = ref.read(apiClientProvider);
      api.onSessionExpired = controller.expireSession;
      ref.onDispose(() => api.onSessionExpired = null);
      controller.restore();
      return controller;
    });

class AuthController extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthController(this.repository) : super(const AsyncLoading());
  final AuthRepository repository;
  int _operation = 0;

  Future<void> restore() async {
    final operation = ++_operation;
    final result = await AsyncValue.guard(repository.restore);
    if (mounted && operation == _operation) {
      state = result.hasError ? const AsyncData(null) : result;
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
    // Clear visible data before waiting for storage or the network.
    ++_operation;
    state = const AsyncData(null);
    await repository.logout();
  }

  void expireSession() {
    ++_operation;
    if (mounted) state = const AsyncData(null);
  }

  Future<void> clearLocalSession() async {
    ++_operation;
    state = const AsyncData(null);
    await repository.clearLocalSession();
  }

  Future<void> deleteAccount() async {
    final operation = ++_operation;
    await repository.deleteAccount();
    if (mounted && operation == _operation) state = const AsyncData(null);
  }

  Future<void> _run(Future<AuthUser> Function() action) async {
    final operation = ++_operation;
    // Do not retain the previous user while the next login is pending. Keeping
    // this as AsyncData also preserves the login form instead of showing splash.
    state = const AsyncData(null);
    final result = await AsyncValue.guard(action);
    if (mounted && operation == _operation) state = result;
  }
}
