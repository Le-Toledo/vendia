import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/widgets/kpi_card.dart';

void main() {
  testWidgets('KpiCard adapts to small constraints without overflow', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 90,
            height: 90,
            child: KpiCard(
              title: 'Clientes com nome longo',
              value: '18',
              icon: Icons.people_outline,
              iconColor: Colors.blue,
              subtitle: '+3 este mês',
            ),
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.textContaining('Clientes'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
  });
}
