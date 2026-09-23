import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_controller.dart';
import '../../../core/data/business_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = ref.read(authControllerProvider).valueOrNull;

    _nameController.text = user?.name ?? '';
    _companyController.text = user?.companyName ?? '';
    _cnpjController.text = user?.cpfCnpj ?? '';
    _phoneController.text = user?.phone ?? '';
    _emailController.text = user?.email ?? '';
    _addressController.text = user?.address ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _cnpjController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      await ref.read(authControllerProvider.notifier).logout();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sessão encerrada neste dispositivo. Não foi possível confirmar a saída no servidor.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil da Empresa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar / Logo Section
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          'CS',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _companyController.text,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'Nome Completo',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Nome da Empresa / Fantasia',
              controller: _companyController,
            ),
            const SizedBox(height: 16),
            CustomTextField(label: 'CPF ou CNPJ', controller: _cnpjController),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Telefone de Contato',
              controller: _phoneController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'E-mail Comercial',
              controller: _emailController,
              enabled: false,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Endereço Comercial',
              controller: _addressController,
            ),
            const SizedBox(height: 28),

            CustomButton(
              text: 'Salvar Perfil',
              onPressed: () async {
                try {
                  await ref
                      .read(businessRepositoryProvider)
                      .save('/users/profile', {
                        'fullName': _nameController.text.trim(),
                        if (_companyController.text.trim().isNotEmpty)
                          'companyName': _companyController.text.trim(),
                        if (_cnpjController.text.trim().isNotEmpty)
                          'cpfCnpj': _cnpjController.text.trim(),
                        if (_phoneController.text.trim().isNotEmpty)
                          'phone': _phoneController.text.trim(),
                        if (_addressController.text.trim().isNotEmpty)
                          'address': _addressController.text.trim(),
                      }, put: true);
                  await ref.read(authControllerProvider.notifier).restore();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil atualizado.')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                }
              },
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.red),
              ),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sair do Aplicativo (Logout)',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => _logout(),
            ),
          ],
        ),
      ),
    );
  }
}
