import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@vendeai.com.br');
  final _passwordController = TextEditingController(text: 'Senha123!');
  bool _isLoading = false;

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/dashboard');
      }
    }
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
                      child: const Icon(Icons.auto_awesome,
                          color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'VendeAI',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5),
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

                // Form Fields
                CustomTextField(
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Insira um e-mail válido'
                      : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Senha',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) => v == null || v.length < 6
                      ? 'Mínimo de 6 caracteres'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Esqueceu a senha?',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: 'Entrar no VendeAI',
                  isLoading: _isLoading,
                  onPressed: _onLogin,
                ),
                const SizedBox(height: 16),

                // Google Login Option
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.g_mobiledata,
                        size: 28, color: Colors.red),
                    label: const Text('Continuar com Google'),
                    onPressed: () => context.go('/dashboard'),
                  ),
                ),
                const SizedBox(height: 32),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Ainda não tem conta? '),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: const Text(
                        'Cadastre-se grátis',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
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
