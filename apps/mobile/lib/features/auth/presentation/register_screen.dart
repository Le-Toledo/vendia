import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../application/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          company: _companyController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);

    final state = ref.read(authControllerProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível criar a conta. Verifique os dados e tente novamente.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta no VendeAI')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comece em menos de 1 minuto 🚀',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crie sua conta para automatizar orçamentos, contratos e finanças.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  label: 'Nome Completo',
                  hint: 'João Silva',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'E-mail Profissional',
                  hint: 'joao@empresa.com.br',
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
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Nome da Sua Empresa ou Negócio',
                  hint: 'Silva Serviços MEI',
                  controller: _companyController,
                  prefixIcon: Icons.business_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Senha de Acesso',
                  hint:
                      'Mínimo 10 caracteres, com maiúscula, minúscula e número',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Informe uma senha';
                    }

                    if (v.length < 10) {
                      return 'A senha deve ter no mínimo 10 caracteres';
                    }

                    if (!RegExp(r'[A-Z]').hasMatch(v)) {
                      return 'Inclua pelo menos uma letra maiúscula';
                    }

                    if (!RegExp(r'[a-z]').hasMatch(v)) {
                      return 'Inclua pelo menos uma letra minúscula';
                    }

                    if (!RegExp(r'[0-9]').hasMatch(v)) {
                      return 'Inclua pelo menos um número';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Criar Minha Conta',
                  isLoading: _isLoading,
                  onPressed: _onRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
