import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/business_providers.dart';

class QuoteFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? quoteToEdit;

  const QuoteFormScreen({super.key, this.quoteToEdit});

  @override
  ConsumerState<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends ConsumerState<QuoteFormScreen> {
  String? _selectedClientId;
  final _discountController = TextEditingController(text: '0');
  final _notesController = TextEditingController(
    text: 'Validade da proposta: 15 dias.',
  );

  final List<Map<String, dynamic>> _items = [
    {'description': 'Novo Serviço / Produto', 'qty': 1, 'price': 0.0},
  ];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final quote = widget.quoteToEdit;
    if (quote != null) {
      _selectedClientId = quote['clientId'] as String?;
      _discountController.text = quote['discount']?.toString() ?? '0';
      _notesController.text = quote['notes'] as String? ?? '';
      final existingItems = quote['items'] as List?;
      if (existingItems != null && existingItems.isNotEmpty) {
        _items
          ..clear()
          ..addAll(
            existingItems.map(
              (item) => {
                'description': item['description'],
                'qty': item['quantity'],
                'price': double.parse(item['unitPrice'].toString()),
              },
            ),
          );
      }
    }
  }

  double get _subtotal => _items.fold(
    0.0,
    (sum, i) => sum + ((i['qty'] as int) * (i['price'] as double)),
  );
  double get _discount => double.tryParse(_discountController.text) ?? 0.0;
  double get _total => (_subtotal - _discount).clamp(0.0, double.infinity);

  @override
  void dispose() {
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add({
        'description': 'Novo Serviço / Produto',
        'qty': 1,
        'price': 500.0,
      });
    });
  }

  Future<void> _save() async {
    if (_selectedClientId == null ||
        _items.any(
          (item) =>
              (item['price'] as double) < 0 ||
              (item['description'] as String).trim().isEmpty,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um cliente e revise os itens.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(businessRepositoryProvider).save('/quotes', {
        'clientId': _selectedClientId,
        'discount': _discount,
        'notes': _notesController.text.trim(),
        'status': widget.quoteToEdit?['status'] ?? 'DRAFT',
        'items': _items
            .map(
              (item) => {
                'description': item['description'],
                'quantity': item['qty'],
                'unitPrice': item['price'],
              },
            )
            .toList(),
      }, id: widget.quoteToEdit?['id'] as String?);
      ref.invalidate(quotesProvider);
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
        title: Text(
          widget.quoteToEdit == null ? 'Novo orçamento' : 'Editar orçamento',
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text(
              'Salvar',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Dropdown Selection
            const Text(
              'Selecionar Cliente',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: ref
                    .watch(clientsProvider)
                    .when(
                      loading: () => const LinearProgressIndicator(),
                      error: (error, _) => Text(error.toString()),
                      data: (clients) => DropdownButton<String>(
                        value: clients.any((c) => c['id'] == _selectedClientId)
                            ? _selectedClientId
                            : null,
                        hint: const Text('Selecione um cliente'),
                        isExpanded: true,
                        items: clients
                            .map(
                              (c) => DropdownMenuItem(
                                value: c['id'] as String,
                                child: Text(c['name'] as String),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedClientId = val),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // Items List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Itens do Orçamento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Adicionar Item'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: item['description'] as String,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                          ),
                          onChanged: (value) => item['description'] = value,
                        ),
                      ),
                      Text('Qtd: ${item['qty']}'),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          initialValue: (item['price'] as double)
                              .toStringAsFixed(2),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Valor'),
                          onChanged: (value) {
                            item['price'] =
                                double.tryParse(value.replaceAll(',', '.')) ??
                                0.0;
                            setState(() {});
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          if (_items.length > 1) {
                            setState(() => _items.removeAt(idx));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Calculations & Discount
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text(
                        Formatters.currency(_subtotal),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Desconto (R\$):'),
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: TextField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        Formatters.currency(_total),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.income,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'Observações e Condições',
              controller: _notesController,
              maxLines: 2,
            ),
            const SizedBox(height: 28),

            CustomButton(
              text: widget.quoteToEdit == null
                  ? 'Criar orçamento'
                  : 'Salvar alterações',
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
