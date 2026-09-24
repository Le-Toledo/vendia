import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/data/business_providers.dart';
import 'package:vendeai_mobile/core/data/business_repository.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/features/auth/application/auth_controller.dart';
import 'package:vendeai_mobile/features/auth/data/auth_repository.dart';
import 'package:vendeai_mobile/features/dashboard/presentation/dashboard_screen.dart';

class PendingLogoutRepository extends AuthRepository {
  PendingLogoutRepository() : super(ApiClient());
  final completion = Completer<void>();
  @override
  Future<AuthUser> restore() async =>
      const AuthUser(id: 'a', email: 'a@example.com', name: 'A');
  @override
  Future<void> logout() => completion.future;
}

class DashboardRepository extends BusinessRepository {
  DashboardRepository() : super(ApiClient());
  @override
  Future<Map<String, dynamic>> get(String path) async => {
    'financial': {'totalIncome': 0, 'totalExpense': 0, 'balance': 0},
    'metrics': {'clientCount': 0, 'quoteCount': 0, 'contractCount': 0},
    'recentActivities': [],
  };
}

void main() {
  testWidgets(
    'dashboard hides previous account while logout navigation is pending',
    (tester) async {
      final repository = PendingLogoutRepository();
      final controller = AuthController(repository);
      await controller.restore();
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith((_) => controller),
          businessRepositoryProvider.overrideWithValue(DashboardRepository()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Olá, A 👋'), findsOneWidget);
      final logout = controller.logout();
      await tester.pump();
      expect(find.text('Olá, A 👋'), findsNothing);
      expect(repository.completion.isCompleted, isFalse);
      repository.completion.complete();
      await logout;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
