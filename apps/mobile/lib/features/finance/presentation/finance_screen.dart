import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/kpi_card.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String _selectedFilter = 'TODOS';

  final List<Map<String, dynamic>> _entries = [
    {
      'description': 'Desenvolvimento de App Mobile',
      'amount': 4000.0,
      'type': 'INCOME',
      'category': 'Vendas de Serviços',
      'date': '02/08/2026',
    },
    {
      'description': 'Infraestrutura Cloud & Servidores',
      'amount': 250.0,
      'type': 'EXPENSE',
      'category': 'Software & Ferramentas',
      'date': '01/08/2026',
    },
    {
      'description': 'Consultoria de Tecnologia',
      'amount': 3500.0,
      'type': 'INCOME',
      'category': 'Consultoria',
      'date': '28/07/2026',
    },
    {
      'description': 'Anúncios Instagram e Meta Ads',
      'amount': 400.0,
      'type': 'EXPENSE',
      'category': 'Marketing & Anúncios',
      'date': '25/07/2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _entries.where((e) {
      if (_selectedFilter == 'RECEITAS') return e['type'] == 'INCOME';
      if (_selectedFilter == 'DESPESAS') return e['type'] == 'EXPENSE';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão Financeira'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Row
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Entradas',
                    value: Formatters.currency(7500.0),
                    icon: Icons.arrow_downward,
                    iconColor: AppColors.income,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    title: 'Saídas',
                    value: Formatters.currency(650.0),
                    icon: Icons.arrow_upward,
                    iconColor: AppColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Financial Monthly Chart (FL Chart)
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Desempenho Mensal (Receitas vs Despesas)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                const labels = ['Mai', 'Jun', 'Jul', 'Ago'];
                                return Text(labels[val.toInt() % labels.length],
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey));
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [
                            BarChartRodData(
                                toY: 5, color: AppColors.income, width: 12)
                          ]),
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(
                                toY: 8, color: AppColors.income, width: 12)
                          ]),
                          BarChartGroupData(x: 2, barRods: [
                            BarChartRodData(
                                toY: 6, color: AppColors.income, width: 12)
                          ]),
                          BarChartGroupData(x: 3, barRods: [
                            BarChartRodData(
                                toY: 10, color: AppColors.income, width: 12)
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text('Extrato Financeiro',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Row(
                  children: ['TODOS', 'RECEITAS', 'DESPESAS'].map((f) {
                    final isSelected = _selectedFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(f,
                            style: TextStyle(
                                fontSize: 10,
                                color: isSelected ? Colors.white : null)),
                        selectedColor: AppColors.primary,
                        onSelected: (_) => setState(() => _selectedFilter = f),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Entries List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final e = filtered[index];
                final isIncome = e['type'] == 'INCOME';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              (isIncome ? AppColors.income : AppColors.expense)
                                  .withValues(alpha: 0.15),
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color:
                                isIncome ? AppColors.income : AppColors.expense,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e['description'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('${e['category']} • ${e['date']}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          '${isIncome ? '+' : '-'} ${Formatters.currency(e['amount'] as double)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isIncome ? AppColors.income : AppColors.expense,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lançamento registrado com sucesso!')),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Lançamento',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
