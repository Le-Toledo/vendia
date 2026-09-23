import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/core/network/api_providers.dart';
import 'package:vendeai_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'unit/api_session_test.dart' show MemoryStorage, TestAdapter, body;

void main() {
  testWidgets(
    'password recovery sends email and submits a matching new password',
    (tester) async {
      final requests = <String>[];
      final api = ApiClient(storage: MemoryStorage());
      api.dio.httpClientAdapter = TestAdapter((options) {
        requests.add(options.path);
        return body('{"data":{"message":"OK"}}', 200);
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(api)],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.tap(find.text('Enviar código por email'));
      await tester.pumpAndSettle();
      expect(requests, ['/auth/forgot-password']);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), 'a' * 48);
      await tester.enterText(fields.at(2), 'StrongPassword1!');
      await tester.enterText(fields.at(3), 'wrong');
      await tester.ensureVisible(find.text('Salvar nova senha'));
      await tester.tap(find.text('Salvar nova senha'));
      await tester.pump();
      expect(requests.length, 1);
      await tester.enterText(fields.at(3), 'StrongPassword1!');
      await tester.ensureVisible(find.text('Salvar nova senha'));
      await tester.tap(find.text('Salvar nova senha'));
      await tester.pumpAndSettle();
      expect(requests, ['/auth/forgot-password', '/auth/reset-password']);
      expect(find.text('Abrir'), findsOneWidget);
    },
  );
}
