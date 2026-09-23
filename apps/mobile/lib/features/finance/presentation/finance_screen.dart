import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/business_providers.dart';
import '../../../core/utils/formatters.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  Future<void> _entryForm(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? entry,
  }) async {
    final editing = entry != null;

    final description = TextEditingController(
      text: editing ? entry['description']?.toString() ?? '' : '',
    );

    final amount = TextEditingController(
      text: editing ? entry['amount']?.toString() ?? '' : '',
    );

    var type = editing ? entry['type']?.toString() ?? 'INCOME' : 'INCOME';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: Text(editing ? 'Editar lançamento' : 'Novo lançamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Valor'),
              ),
              DropdownButton<String>(
                value: type,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'INCOME', child: Text('Receita')),
                  DropdownMenuItem(value: 'EXPENSE', child: Text('Despesa')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => type = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(editing ? 'Salvar alterações' : 'Salvar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) {
      description.dispose();
      amount.dispose();
      return;
    }

    final parsedAmount = double.tryParse(
      amount.text.trim().replaceAll(',', '.'),
    );

    if (description.text.trim().isEmpty ||
        parsedAmount == null ||
        parsedAmount <= 0) {
      description.dispose();
      amount.dispose();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informe uma descrição e um valor válido.'),
          ),
        );
      }
      return;
    }

    try {
      await ref.read(businessRepositoryProvider).save('/finance/entries', {
        'description': description.text.trim(),
        'amount': parsedAmount,
        'type': type,
      }, id: editing ? entry['id']?.toString() : null);

      ref.invalidate(financeEntriesProvider);
      ref.invalidate(dashboardProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editing
                  ? 'Lançamento atualizado com sucesso.'
                  : 'Lançamento criado com sucesso.',
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      description.dispose();
      amount.dispose();
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Excluir lançamento?'),
            content: const Text('Essa ação não poderá ser desfeita.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> entry,
  ) async {
    final confirmed = await _confirmDelete(context);
    if (!confirmed) return;

    try {
      await ref
          .read(businessRepositoryProvider)
          .delete('/finance/entries/${entry['id']}');

      ref.invalidate(financeEntriesProvider);
      ref.invalidate(dashboardProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lançamento excluído com sucesso.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(financeEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Finanças')),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(financeEntriesProvider),
            child: Text(
              'Tentar novamente\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum lançamento financeiro.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(financeEntriesProvider);
              await ref.read(financeEntriesProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, index) {
                final entry = items[index];
                final income = entry['type'] == 'INCOME';

                return Dismissible(
                  key: ValueKey(entry['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => _confirmDelete(context),
                  onDismissed: (_) async {
                    try {
                      await ref
                          .read(businessRepositoryProvider)
                          .delete('/finance/entries/${entry['id']}');

                      ref.invalidate(financeEntriesProvider);
                      ref.invalidate(dashboardProvider);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lançamento excluído com sucesso.'),
                          ),
                        );
                      }
                    } catch (error) {
                      ref.invalidate(financeEntriesProvider);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    }
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          (income ? AppColors.income : AppColors.expense)
                              .withValues(alpha: .15),
                      child: Icon(
                        income ? Icons.arrow_downward : Icons.arrow_upward,
                        color: income ? AppColors.income : AppColors.expense,
                      ),
                    ),
                    title: Text(entry['description']?.toString() ?? ''),
                    subtitle: Text(
                      entry['entryDate']?.toString().split('T').first ?? '',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${income ? '+' : '-'} ${Formatters.currency(double.parse(entry['amount'].toString()))}',
                          style: TextStyle(
                            color: income
                                ? AppColors.income
                                : AppColors.expense,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Opções',
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await _entryForm(context, ref, entry: entry);
                            } else if (value == 'delete') {
                              await _deleteEntry(context, ref, entry);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined),
                                  SizedBox(width: 12),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline),
                                  SizedBox(width: 12),
                                  Text('Excluir'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _entryForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Lançamento'),
      ),
    );
  }
}
