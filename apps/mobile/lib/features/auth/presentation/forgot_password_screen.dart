import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_providers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _requested = false;
  bool _busy = false;
  String? _message;
  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final api = ref.read(apiClientProvider);
    try {
      if (!_requested) {
        await api.dio.post(
          '/auth/forgot-password',
          data: {'email': _email.text.trim()},
        );
        if (!mounted) return;
        setState(() {
          _requested = true;
          _message =
              'Se houver uma conta com senha para este email, você receberá um código. Confira também o spam. O código vale por 15 minutos.';
        });
      } else {
        await api.dio.post(
          '/auth/reset-password',
          data: {
            'email': _email.text.trim(),
            'token': _code.text.trim(),
            'password': _password.text,
          },
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha atualizada. Entre com sua nova senha.'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) setState(() => _message = api.readableError(error).message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Recuperar Senha')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recupere seu acesso',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'E-mail',
              hint: 'seu@email.com',
              controller: _email,
              enabled: !_busy && !_requested,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || !v.trim().contains('@')
                  ? 'Informe um e-mail válido'
                  : null,
            ),
            if (_requested) ...[
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Código recebido por email',
                hint: 'Cole o código completo',
                controller: _code,
                autocorrect: false,
                enableSuggestions: false,
                validator: (v) =>
                    RegExp(r'^[a-f0-9]{48}$').hasMatch(v?.trim() ?? '')
                    ? null
                    : 'Cole o código completo recebido por email',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nova senha',
                hint: '10 caracteres, maiúscula, minúscula e número',
                controller: _password,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                validator: (v) =>
                    v != null &&
                        v.length >= 10 &&
                        v.length <= 72 &&
                        RegExp(r'[a-z]').hasMatch(v) &&
                        RegExp(r'[A-Z]').hasMatch(v) &&
                        RegExp(r'\d').hasMatch(v)
                    ? null
                    : 'Use de 10 a 72 caracteres, com maiúscula, minúscula e número',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirmar nova senha',
                controller: _confirm,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                validator: (v) =>
                    v == _password.text ? null : 'As senhas não coincidem',
              ),
            ],
            if (_message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(_message!),
              ),
            const SizedBox(height: 24),
            CustomButton(
              text: _requested
                  ? 'Salvar nova senha'
                  : 'Enviar código por email',
              isLoading: _busy,
              onPressed: _submit,
            ),
            if (_requested)
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        _requested = false;
                        _message = null;
                        _code.clear();
                        _password.clear();
                        _confirm.clear();
                      }),
                child: const Text('Solicitar outro código ou corrigir email'),
              ),
          ],
        ),
      ),
    ),
  );
}
