import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_providers.dart';
import 'business_repository.dart';
import '../../features/auth/application/auth_controller.dart';

final businessUserProvider = Provider<String?>(
  (ref) =>
      ref.watch(authControllerProvider.select((auth) => auth.valueOrNull?.id)),
);

Future<List<Map<String, dynamic>>> _list(Ref ref, String path) {
  final userId = ref.watch(businessUserProvider);
  if (userId == null) return Future.value([]);
  return ref.watch(businessRepositoryProvider).list(path);
}

final businessRepositoryProvider = Provider<BusinessRepository>(
  (ref) => BusinessRepository(ref.watch(apiClientProvider)),
);
final clientsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) => _list(ref, '/clients'),
);
final quotesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) => _list(ref, '/quotes'),
);
final contractsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => _list(ref, '/contracts'),
    );
final financeEntriesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => _list(ref, '/finance/entries'),
    );
final categoriesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => _list(ref, '/finance/categories'),
    );
final dashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) {
  final userId = ref.watch(businessUserProvider);
  if (userId == null) return Future.value(<String, dynamic>{});
  return ref.watch(businessRepositoryProvider).get('/finance/summary');
});
