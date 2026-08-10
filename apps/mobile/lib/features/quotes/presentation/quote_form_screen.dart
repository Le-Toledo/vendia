import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_card.dart';

class QuoteFormScreen extends StatefulWidget {
  final Map<String, dynamic>? quoteToEdit;

  const QuoteFormScreen({super.key, this.quoteToEdit});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  String _selectedClient = 'Empresa Exemplo Ltda';
  final _discountController = TextEditingController(text: '0');
  final _notesController =
      TextEditingController(text: 'Validade da proposta: 15 dias.');

  final List<Map<String, dynamic>> _items = [
    {
      'description': 'Desenvolvimento de Solução Mobile',
      'qty': 1,
      'price': 3500.0
    },
    {
      'description': 'Integração de Inteligência Artificial',
      'qty': 1,
      'price': 1000.0
    },
  ];

  double get _subtotal => _items.fold(
      0.0, (sum, i) => sum + ((i['qty'] as int) * (i['price'] as double)));
  double get _discount => double.tryParse(_discountController.text) ?? 0.0;
  double get _total => (_subtotal - _discount).clamp(0.0, double.infinity);

  void _addItem() {
    setState(() {
      _items.add(
          {'description': 'Novo Serviço / Produto', 'qty': 1, 'price': 500.0});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Orçamento'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rascunho salvo com sucesso!')),
              );
              context.pop();
            },
            child: const Text('Salvar Rascunho',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Dropdown Selection
            const Text('Selecionar Cliente',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                child: DropdownButton<String>(
                  value: _selectedClient,
                  isExpanded: true,
                  items: [
                    'Empresa Exemplo Ltda',
                    'Juliana Alencar Architecture',
                    'Padaria & Confeitaria Solar'
                  ]
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedClient = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Items List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text('Itens do Orçamento',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
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
                        child: Text(
                          item['description'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      Text('Qtd: ${item['qty']}'),
                      const SizedBox(width: 12),
                      Text(Formatters.currency(item['price'] * item['qty']),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: Colors.red),
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
                      Text(Formatters.currency(_subtotal),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
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
                                  horizontal: 10, vertical: 8)),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        Formatters.currency(_total),
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.income),
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
              text: 'Gerar e Enviar Orçamento',
              icon: Icons.picture_as_pdf,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Orçamento gerado e PDF criado com sucesso!')),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
