import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/core/network/api_providers.dart';
import 'package:vendeai_mobile/features/chat_ai/presentation/chat_ai_screen.dart';
import 'unit/api_session_test.dart' show MemoryStorage, TestAdapter, body;

void main() {
  for (final accept in [false, true]) {
    testWidgets('AI request requires explicit consent (accept=$accept)', (
      tester,
    ) async {
      var sends = 0;
      var approvals = 0;
      final api = ApiClient(storage: MemoryStorage());
      api.dio.httpClientAdapter = TestAdapter((options) {
        if (options.path == '/app/config') {
          return body(
            '{"data":{"ai":{"id":"groq","name":"Groq","consentVersion":"v1"}}}',
            200,
          );
        }
        if (options.path == '/users/me') {
          return body('{"data":{"settings":{}}}', 200);
        }
        if (options.path == '/users/ai-consent') {
          approvals++;
          return body('{"data":{"approved":true}}', 200);
        }
        sends++;
        return body('{"data":{"content":"Resposta"}}', 200);
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(api)],
          child: const MaterialApp(home: ChatAiScreen()),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Minha pergunta');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Autorizar uso de IA'), findsOneWidget);
      expect(sends, 0);
      await tester.tap(find.text(accept ? 'Autorizar envio' : 'Agora não'));
      await tester.pumpAndSettle();
      expect(sends, accept ? 1 : 0);
      expect(approvals, accept ? 1 : 0);
      if (!accept) {
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Minha pergunta',
        );
      }
    });
  }
}
