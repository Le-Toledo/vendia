import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';

class QuotesScreen extends StatelessWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quotes = [
      {
        'code': 'ORC-2026-001',
        'client': 'Empresa Exemplo Ltda',
        'total': 4000.0,
        'status': 'APROVADO',
        'date': '02/08/2026',
      },
      {
        'code': 'ORC-2026-002',
        'client': 'Juliana Alencar Architecture',
        'total': 2800.0,
        'status': 'ENVIADO',
        'date': '01/08/2026',
      },
      {
        'code': 'ORC-2026-003',
        'client': 'Padaria & Confeitaria Solar',
        'total': 1500.0,
        'status': 'RASCUNHO',
        'date': '29/07/2026',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_rounded, color: AppColors.primary),
            onPressed: () => context.push('/quotes/new'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          final q = quotes[index];
          final status = q['status'] as String;
          Color statusColor = AppColors.warning;
          if (status == 'APROVADO') statusColor = AppColors.income;
          if (status == 'RASCUNHO') statusColor = Colors.grey;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              onTap: () => context.push('/quotes/new', extra: q),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          q['code'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q['client'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.currency(q['total'] as double),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf_outlined,
                                color: Colors.red),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Gerando e baixando PDF do Orçamento...')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined,
                                color: AppColors.primary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Compartilhando PDF via WhatsApp...')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded,
                                color: Colors.grey),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Orçamento duplicado como Rascunho!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/quotes/new'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Orçamento',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
