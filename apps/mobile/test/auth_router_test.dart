import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/features/auth/application/auth_controller.dart';
import 'package:vendeai_mobile/features/auth/data/auth_repository.dart';
import 'package:vendeai_mobile/features/auth/presentation/login_screen.dart';
import 'package:vendeai_mobile/main.dart';

class RejectingRepository extends AuthRepository {
  RejectingRepository() : super(ApiClient());

  @override
  Future<AuthUser> login(String email, String password) async {
    throw Exception('Invalid credentials');
  }

  @override
  Future<AuthUser> loginWithApple() async {
    throw Exception('Apple unavailable');
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    throw Exception('Google unavailable');
  }
}

void main() {
  testWidgets(
    'iOS offers Apple login without losing the existing login options',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AuthController(RejectingRepository())..expireSession();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authControllerProvider.overrideWith((ref) => controller)],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      expect(find.text('Continuar com Google'), findsOneWidget);
      expect(find.text('Esqueceu a senha?'), findsOneWidget);
      expect(find.text('Cadastre-se grátis'), findsOneWidget);
      expect(find.text('Digite sua senha'), findsOneWidget);
      await tester.ensureVisible(find.text('Continuar com Apple'));
      await tester.tap(find.text('Continuar com Apple'));
      await tester.pumpAndSettle();
      expect(
        find.text('Não foi possível entrar com Apple. Tente novamente.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'Google failure shows feedback without losing email or password',
    (tester) async {
      final controller = AuthController(RejectingRepository());
      controller.expireSession();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authControllerProvider.overrideWith((ref) => controller)],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'missing@example.com');
      await tester.enterText(fields.at(1), 'incorrect-password');
      await tester.ensureVisible(find.text('Continuar com Google'));
      await tester.tap(find.text('Continuar com Google'));
      await tester.pumpAndSettle();
      expect(
        find.text('Não foi possível entrar com Google. Tente novamente.'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextFormField>(fields.at(0)).controller!.text,
        'missing@example.com',
      );
      expect(
        tester.widget<TextFormField>(fields.at(1)).controller!.text,
        'incorrect-password',
      );
    },
  );
  testWidgets('failed login preserves router, form and generic error', (
    tester,
  ) async {
    final controller = AuthController(RejectingRepository());
    controller.expireSession();
    final container = ProviderContainer(
      overrides: [authControllerProvider.overrideWith((ref) => controller)],
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    final loginState = tester.state(find.byType(LoginScreen));
    final fields = find.byType(TextFormField);
    expect(
      tester.widget<TextFormField>(fields.at(0)).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<TextFormField>(fields.at(1)).controller!.text,
      isEmpty,
    );
    expect(find.text('Digite sua senha'), findsOneWidget);
    await tester.tap(fields.at(1));
    await tester.pump();
    final passwordInput = tester.widget<EditableText>(
      find.descendant(of: fields.at(1), matching: find.byType(EditableText)),
    );
    expect(passwordInput.controller.text, isEmpty);
    expect(passwordInput.obscureText, isTrue);
    expect(passwordInput.autofillHints, isNull);
    expect(passwordInput.autocorrect, isFalse);
    expect(passwordInput.enableSuggestions, isFalse);
    expect(tester.testTextInput.editingState!['text'], isEmpty);
    expect(tester.testTextInput.setClientArgs!['autofill'], isNull);
    await tester.enterText(fields.at(0), 'missing@example.com');
    await tester.enterText(fields.at(1), 'incorrect-password');
    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.ensureVisible(find.text('Entrar no VendAI'));
      await tester.tap(find.text('Entrar no VendAI'));
      await tester.pumpAndSettle();
      expect(identical(container.read(routerProvider), router), isTrue);
      expect(
        identical(tester.state(find.byType(LoginScreen)), loginState),
        isTrue,
      );
      expect(
        tester.widget<TextFormField>(fields.at(0)).controller!.text,
        'missing@example.com',
      );
      expect(
        tester.widget<TextFormField>(fields.at(1)).controller!.text,
        'incorrect-password',
      );
      expect(
        find.text(
          'Não foi possível fazer login. Verifique seu e-mail e sua senha.',
        ),
        findsOneWidget,
      );
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('session restoration exits splash using the same router', (
    tester,
  ) async {
    final controller = AuthController(RejectingRepository());
    final container = ProviderContainer(
      overrides: [authControllerProvider.overrideWith((ref) => controller)],
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    expect(router.routeInformationProvider.value.uri.path, '/splash');
    controller.expireSession();
    await tester.pumpAndSettle();
    expect(identical(container.read(routerProvider), router), isTrue);
    expect(router.routeInformationProvider.value.uri.path, '/login');
    expect(find.byType(LoginScreen), findsOneWidget);
    router.go('/profile');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/login');
    await tester.pumpWidget(const SizedBox());
  });
}
