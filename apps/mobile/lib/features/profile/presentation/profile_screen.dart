import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Carlos Eduardo Silva');
  final _companyController =
      TextEditingController(text: 'Silva Tech Services Ltda');
  final _cnpjController = TextEditingController(text: '12.345.678/0001-90');
  final _phoneController = TextEditingController(text: '(11) 98765-4321');
  final _emailController =
      TextEditingController(text: 'carlos@silvatech.com.br');
  final _addressController =
      TextEditingController(text: 'Av. Paulista, 1000 - São Paulo, SP');

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
                        child: Text('CS',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt,
                            size: 14, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_nameController.text,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_companyController.text,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
            CustomTextField(
              label: 'CPF ou CNPJ',
              controller: _cnpjController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Telefone de Contato',
              controller: _phoneController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'E-mail Comercial',
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Endereço Comercial',
              controller: _addressController,
            ),
            const SizedBox(height: 28),

            CustomButton(
              text: 'Salvar Perfil',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Perfil da empresa atualizado com sucesso!')),
                );
              },
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.red),
              ),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sair do Aplicativo (Logout)',
                  style: TextStyle(color: Colors.red)),
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}
