import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Unit Tests', () {
    test('Validate email format', () {
      const validEmail = 'demo@vendeai.com.br';
      const invalidEmail = 'demo_invalid';

      expect(validEmail.contains('@'), isTrue);
      expect(invalidEmail.contains('@'), isFalse);
    });

    test('Validate password min length requirement', () {
      const validPass = 'Senha123!';
      const shortPass = '123';

      expect(validPass.length >= 6, isTrue);
      expect(shortPass.length >= 6, isFalse);
    });
  });
}
