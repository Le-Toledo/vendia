import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/business_providers.dart';
import '../../../core/widgets/delete_confirmation.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? clientToEdit;

  const ClientFormScreen({super.key, this.clientToEdit});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  bool _busy = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cpfCnpjController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final c = widget.clientToEdit;
    _nameController = TextEditingController(text: c?['name'] ?? '');
    _companyController = TextEditingController(text: c?['companyName'] ?? '');
    _emailController = TextEditingController(text: c?['email'] ?? '');
    _phoneController = TextEditingController(text: c?['phone'] ?? '');
    _cpfCnpjController = TextEditingController(text: c?['cpfCnpj'] ?? '');
    _addressController = TextEditingController(text: c?['address'] ?? '');
    _notesController = TextEditingController(text: c?['notes'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfCnpjController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_busy) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _busy = true);
      try {
        await ref.read(businessRepositoryProvider).save('/clients', {
          'name': _nameController.text.trim(),
          if (_companyController.text.trim().isNotEmpty)
            'companyName': _companyController.text.trim(),
          if (_emailController.text.trim().isNotEmpty)
            'email': _emailController.text.trim(),
          if (_phoneController.text.trim().isNotEmpty)
            'phone': _phoneController.text.trim(),
          if (_cpfCnpjController.text.trim().isNotEmpty)
            'cpfCnpj': _cpfCnpjController.text.trim(),
          if (_addressController.text.trim().isNotEmpty)
            'address': _addressController.text.trim(),
          if (_notesController.text.trim().isNotEmpty)
            'notes': _notesController.text.trim(),
        }, id: widget.clientToEdit?['id'] as String?);
        if (!mounted) return;
        ref.invalidate(clientsProvider);
        context.pop();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final confirmed = await confirmDeletion(context, 'cliente');
      if (!mounted || !confirmed) return;
      await ref
          .read(businessRepositoryProvider)
          .delete('/clients/${widget.clientToEdit!['id']}');
      if (!mounted) return;
      ref.invalidate(clientsProvider);
      ref.invalidate(dashboardProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cliente excluído.')));
      context.go('/clients');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(deletionError(error, 'cliente'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.clientToEdit != null;

    return Scaffold(
      // ensure scaffold resizes when keyboard appears to avoid bottom overflow
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
        actions: [
          if (isEditing)
            TextButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir cliente'),
              onPressed: _busy ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // allow dismissing keyboard by dragging and ensure viewInsets are respected
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Nome Completo ou Razão Social *',
                  hint: 'Ex: Carlos Oliveira',
                  controller: _nameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nome é obrigatório' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Nome da Empresa',
                  hint: 'Ex: Oliveira Soluções',
                  controller: _companyController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'E-mail',
                  hint: 'cliente@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Telefone / WhatsApp',
                  hint: '(11) 99999-8888',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'CPF ou CNPJ',
                  hint: '000.000.000-00',
                  controller: _cpfCnpjController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Endereço Completo',
                  hint: 'Rua, número, bairro, cidade - UF',
                  controller: _addressController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Observações do Cliente',
                  hint: 'Preferências de contato, condições de pagamento...',
                  controller: _notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: isEditing ? 'Salvar Alterações' : 'Cadastrar Cliente',
                  onPressed: _busy ? null : _onSave,
                  isLoading: _busy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
