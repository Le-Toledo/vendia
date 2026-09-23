import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/business_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';

class ContractsScreen extends ConsumerWidget {
  const ContractsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(contractsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contratos'),
        actions: [
          IconButton(
            tooltip: 'Novo contrato',
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () async {
              await context.push('/contracts/form');
              ref.invalidate(contractsProvider);
            },
          ),
        ],
      ),
      body: contracts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(contractsProvider),
            child: Text(
              'Tentar novamente\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum contrato cadastrado.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(contractsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, index) {
                final contract = items[index];
                final client = contract['client'] as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    onTap: () async {
                      await context.push('/contracts/form', extra: contract);
                      ref.invalidate(contractsProvider);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                contract['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              contract['status'] as String,
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cliente: ${client['name']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatters.currency(
                                double.parse(contract['value'].toString()),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                final confirmed =
                                    await showDialog<bool>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Excluir contrato?'),
                                        content: const Text(
                                          'Esta ação não poderá ser desfeita.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                dialogContext.pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                dialogContext.pop(true),
                                            child: const Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;
                                if (!confirmed) return;
                                try {
                                  await ref
                                      .read(businessRepositoryProvider)
                                      .delete('/contracts/${contract['id']}');
                                  ref.invalidate(contractsProvider);
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error.toString())),
                                    );
                                  }
                                }
                              },
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
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await context.push('/contracts/form');
          ref.invalidate(contractsProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo contrato'),
      ),
    );
  }
}
