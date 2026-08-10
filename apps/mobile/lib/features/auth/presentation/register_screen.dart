import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _onRegister() async {
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
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'E-mail Profissional',
                  hint: 'joao@empresa.com.br',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Insira um e-mail válido'
                      : null,
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
                  hint: 'Mínimo 6 caracteres',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) => v == null || v.length < 6
                      ? 'Mínimo de 6 caracteres'
                      : null,
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
