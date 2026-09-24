import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/features/auth/application/auth_controller.dart';
import 'package:vendeai_mobile/features/auth/data/auth_repository.dart';

class _LoggedOutController extends AuthController {
  _LoggedOutController() : super(AuthRepository(ApiClient())) {
    state = const AsyncData(null);
  }
  @override
  Future<void> restore() async {}
}

void main() {
  testWidgets('VendAI App Smoke Test - Login Screen Initial Render', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((_) => _LoggedOutController()),
        ],
        child: const VendeAiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VendAI'), findsOneWidget);
    expect(find.text('Entrar no VendAI'), findsOneWidget);
  });
}
