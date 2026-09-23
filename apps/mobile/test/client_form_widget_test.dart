import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/features/clients/presentation/client_form_screen.dart';

void main() {
  testWidgets('ClientForm builds and accepts input without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ClientFormScreen()));

    await tester.pumpAndSettle();

    // AppBar title should be present for a new client
    expect(find.text('Novo Cliente'), findsOneWidget);

    // There should be at least one TextFormField to enter text
    final textField = find.byType(TextFormField).first;
    expect(textField, findsOneWidget);

    // Enter some text and verify it's accepted by the widget tree
    await tester.enterText(textField, 'Teste de cliente');
    await tester.pumpAndSettle();

    expect(find.text('Teste de cliente'), findsWidgets);
  });
}
