import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contracts = [
      {
        'title': 'Contrato de Prestação de Serviços de TI',
        'client': 'Empresa Exemplo Ltda',
        'value': 4000.0,
        'status': 'ATIVO',
      },
      {
        'title': 'Contrato de Consultoria e Licenciamento',
        'client': 'Juliana Alencar Architecture',
        'value': 2800.0,
        'status': 'RASCUNHO',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contratos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.primary),
            onPressed: () => context.push('/chat-ai'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final c = contracts[index];
          final isDraft = c['status'] == 'RASCUNHO';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          c['title'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDraft ? Colors.grey : AppColors.income)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          c['status'] as String,
                          style: TextStyle(
                            color: isDraft ? Colors.grey : AppColors.income,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cliente: ${c['client']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.currency(c['value'] as double),
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
                                    content:
                                        Text('Exportando PDF do contrato...')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined,
                                color: AppColors.primary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Compartilhando contrato...')),
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
        onPressed: () => context.push('/chat-ai'),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text('Gerar Contrato com IA',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
