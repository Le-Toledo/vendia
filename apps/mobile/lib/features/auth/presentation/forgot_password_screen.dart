import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esqueceu sua senha? 🔑',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Digite seu e-mail cadastrado e enviaremos um link seguro para redefinição.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            if (!_sent) ...[
              CustomTextField(
                label: 'E-mail',
                hint: 'seu@email.com',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Enviar Instruções',
                onPressed: () {
                  setState(() => _sent = true);
                },
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.income.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.income),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.income, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'E-mail Enviado com Sucesso!',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.income),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
