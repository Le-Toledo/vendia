import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_providers.dart';
import 'business_repository.dart';

final businessRepositoryProvider = Provider<BusinessRepository>(
  (ref) => BusinessRepository(ref.watch(apiClientProvider)),
);
final clientsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) => ref.watch(businessRepositoryProvider).list('/clients'),
);
final quotesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) => ref.watch(businessRepositoryProvider).list('/quotes'),
);
final contractsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref.watch(businessRepositoryProvider).list('/contracts'),
    );
final financeEntriesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref.watch(businessRepositoryProvider).list('/finance/entries'),
    );
final categoriesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) =>
          ref.watch(businessRepositoryProvider).list('/finance/categories'),
    );
final dashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) => ref.watch(businessRepositoryProvider).get('/finance/summary'),
);
