import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/business_providers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ContractFormScreen extends ConsumerStatefulWidget {
  const ContractFormScreen({super.key, this.contractToEdit});
  final Map<String, dynamic>? contractToEdit;

  @override
  ConsumerState<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends ConsumerState<ContractFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final TextEditingController _value;
  String? _clientId;
  String _status = 'DRAFT';
  bool _saving = false;

  bool get _editing => widget.contractToEdit != null;

  @override
  void initState() {
    super.initState();
    final contract = widget.contractToEdit;
    _title = TextEditingController(text: contract?['title']?.toString() ?? '');
    _content = TextEditingController(
      text: contract?['content']?.toString() ?? '',
    );
    _value = TextEditingController(text: contract?['value']?.toString() ?? '0');
    _clientId = contract?['clientId'] as String?;
    _status = contract?['status'] as String? ?? 'DRAFT';
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _value.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um cliente e revise os campos.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(businessRepositoryProvider).save('/contracts', {
        'clientId': _clientId,
        'title': _title.text.trim(),
        'content': _content.text.trim(),
        'value': double.parse(_value.text.replaceAll(',', '.')),
        'status': _status,
      }, id: widget.contractToEdit?['id'] as String?);
      ref.invalidate(contractsProvider);
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Editar contrato' : 'Novo contrato'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ref
                .watch(clientsProvider)
                .when(
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) =>
                      Text('Não foi possível carregar clientes: $error'),
                  data: (clients) => DropdownButtonFormField<String>(
                    initialValue: clients.any((c) => c['id'] == _clientId)
                        ? _clientId
                        : null,
                    decoration: const InputDecoration(labelText: 'Cliente *'),
                    items: clients
                        .map(
                          (client) => DropdownMenuItem<String>(
                            value: client['id'] as String,
                            child: Text(client['name'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _clientId = value),
                  ),
                ),
            const SizedBox(height: 16),
            CustomTextField(label: 'Título *', controller: _title),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Conteúdo do contrato *',
              hint: 'Descreva o objeto, obrigações, prazo e condições.',
              controller: _content,
              maxLines: 10,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _value,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Valor (R\$) *'),
              validator: (value) =>
                  double.tryParse((value ?? '').replaceAll(',', '.')) == null
                  ? 'Informe um valor válido'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items:
                  const {
                        'DRAFT': 'Rascunho',
                        'ACTIVE': 'Ativo',
                        'COMPLETED': 'Concluído',
                        'CANCELLED': 'Cancelado',
                      }.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: _editing ? 'Salvar alterações' : 'Criar contrato',
              icon: Icons.save_outlined,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
