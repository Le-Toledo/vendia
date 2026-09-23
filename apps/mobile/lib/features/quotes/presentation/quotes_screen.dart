import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/business_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';

class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(quotesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_rounded, color: AppColors.primary),
            onPressed: () async {
              await context.push('/quotes/new');
              ref.invalidate(quotesProvider);
            },
          ),
        ],
      ),
      body: quotes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(quotesProvider),
            child: Text(
              'Tentar novamente\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum orçamento criado.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(quotesProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, index) {
                final quote = items[index];
                final status = quote['status'] as String;
                final color = status == 'APPROVED'
                    ? AppColors.income
                    : status == 'DRAFT'
                    ? Colors.grey
                    : AppColors.warning;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    onTap: () async {
                      await context.push('/quotes/detail', extra: quote);
                      ref.invalidate(quotesProvider);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                quote['codeNumber'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(status),
                              side: BorderSide.none,
                              backgroundColor: color.withValues(alpha: .15),
                            ),
                          ],
                        ),
                        Text(
                          (quote['client'] as Map<String, dynamic>)['name']
                              as String,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.currency(
                            double.parse(quote['total'].toString()),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
