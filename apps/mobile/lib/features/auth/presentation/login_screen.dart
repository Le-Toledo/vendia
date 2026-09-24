import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/material.dart';
import '../../privacy/presentation/privacy_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Os campos começam vazios.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  Future<void> _onAppleLogin() async {
    if (_isLoading || _isGoogleLoading || _isAppleLoading) return;
    setState(() => _isAppleLoading = true);
    await ref.read(authControllerProvider.notifier).loginWithApple();
    if (!mounted) return;
    setState(() => _isAppleLoading = false);
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      final error = state.error;
      if (error is SignInWithAppleAuthorizationException &&
          error.code == AuthorizationErrorCode.canceled) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível entrar com Apple. Tente novamente.'),
        ),
      );
    }
  }

  Future<void> _onGoogleLogin() async {
    if (_isLoading || _isGoogleLoading || _isAppleLoading) return;
    setState(() => _isGoogleLoading = true);
    await ref.read(authControllerProvider.notifier).loginWithGoogle();
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);
    if (ref.read(authControllerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível entrar com Google. Tente novamente.'),
        ),
      );
    }
  }

  Future<void> _onLogin() async {
    if (_isLoading || _isGoogleLoading || _isAppleLoading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);

    final state = ref.read(authControllerProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível fazer login. Verifique seu e-mail e sua senha.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo & Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'VendAI',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                const Text(
                  'Bem-vindo de volta! 👋',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Gerencie seu negócio com inteligência artificial em um só lugar.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 36),

                // E-mail
                CustomTextField(
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe seu e-mail';
                    }

                    if (!v.contains('@')) {
                      return 'Insira um e-mail válido';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Senha
                CustomTextField(
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  controller: _passwordController,
                  obscureText: true,
                  // null disables autofill and requests autocomplete="off" on web.
                  autofillHints: null,
                  autocorrect: false,
                  enableSuggestions: false,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Informe sua senha';
                    }

                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                CustomButton(
                  text: 'Entrar no VendAI',
                  isLoading: _isLoading,
                  onPressed: _onLogin,
                ),

                const SizedBox(height: 16),

                // Google Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                      color: Colors.red,
                    ),
                    label: const Text('Continuar com Google'),
                    onPressed: _isLoading || _isGoogleLoading || _isAppleLoading
                        ? null
                        : _onGoogleLogin,
                  ),
                ),

                const SizedBox(height: 32),

                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacyScreen(),
                    ),
                  ),
                  child: const Text('Política de privacidade'),
                ),
                if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
                  IgnorePointer(
                    ignoring: _isLoading || _isGoogleLoading || _isAppleLoading,
                    child: SignInWithAppleButton(
                      onPressed: _onAppleLogin,
                      text: 'Continuar com Apple',
                      height: 50,
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Cadastro
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Ainda não tem conta? '),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: const Text(
                        'Cadastre-se grátis',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
