import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/main.dart';

void main() {
  testWidgets('VendeAI App Smoke Test - Login Screen Initial Render',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VendeAiApp());
    await tester.pumpAndSettle();

    expect(find.text('VendeAI'), findsOneWidget);
    expect(find.text('Entrar no VendeAI'), findsOneWidget);
  });
}
