import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/kpi_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('VendeAI',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, Carlos Silva 👋',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Silva Tech Services',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield, color: AppColors.primary, size: 14),
                      SizedBox(width: 4),
                      Text('Plano PRO',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Financial Summary Banner
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo Atual',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.currency(8500.0),
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0x2210B981),
                              child: Icon(Icons.arrow_downward,
                                  color: AppColors.income, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Receitas',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                                Text(Formatters.currency(12000.0),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.income)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0x22EF4444),
                              child: Icon(Icons.arrow_upward,
                                  color: AppColors.expense, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Despesas',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                                Text(Formatters.currency(3500.0),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.expense)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Central AI Prominent Action Card
            GestureDetector(
              onTap: () => context.push('/chat-ai'),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conversar com a IA',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Crie orçamentos, contratos e mensagens em segundos.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // KPI Grid Cards (responsive: 2 columns on narrow widths)
            LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = constraints.maxWidth < 420 ? 2 : 3;
                final aspect = constraints.maxWidth < 420 ? 1.05 : 0.95;
                return GridView.count(
                  crossAxisCount: crossCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: aspect,
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/clients'),
                      child: const KpiCard(
                        title: 'Clientes',
                        value: '18',
                        icon: Icons.people_outline,
                        iconColor: AppColors.primary,
                        subtitle: '+3 este mês',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/quotes'),
                      child: const KpiCard(
                        title: 'Orçamentos',
                        value: '12',
                        icon: Icons.receipt_long_outlined,
                        iconColor: AppColors.warning,
                        subtitle: '4 pendentes',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/contracts'),
                      child: const KpiCard(
                        title: 'Contratos',
                        value: '8',
                        icon: Icons.description_outlined,
                        iconColor: AppColors.accent,
                        subtitle: '8 ativos',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Access Hub
            const Text(
              'Ações Rápidas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickActionChip(
                      context,
                      'Novo Cliente',
                      Icons.person_add_outlined,
                      () => context.push('/clients/new')),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(context, 'Criar Orçamento',
                      Icons.add_chart, () => context.push('/quotes/new')),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                      context,
                      'Novo Lançamento',
                      Icons.account_balance_wallet_outlined,
                      () => context.push('/finance')),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                      context,
                      'Marketing Hub',
                      Icons.campaign_outlined,
                      () => context.push('/marketing')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Activity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Últimas Atividades',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push('/finance'),
                  child: const Text('Ver tudo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              title: 'Pagamento Recebido',
              subtitle: 'Empresa Exemplo Ltda • Desenvolv. Web',
              amount: '+ R\$ 4.000,00',
              color: AppColors.income,
              icon: Icons.arrow_downward,
            ),
            _buildActivityItem(
              title: 'Assinatura de Software',
              subtitle: 'Servidor VPS & Domínios',
              amount: '- R\$ 180,00',
              color: AppColors.expense,
              icon: Icons.arrow_upward,
            ),
            _buildActivityItem(
              title: 'Orçamento Aprovado',
              subtitle: 'Consultoria de TI • ORC-2026-001',
              amount: 'R\$ 3.500,00',
              color: AppColors.primary,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) context.push('/clients');
          if (index == 2) context.push('/chat-ai');
          if (index == 3) context.push('/quotes');
          if (index == 4) context.push('/finance');
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline), label: 'Clientes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome, size: 28), label: 'IA'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined), label: 'Orçamentos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Finanças'),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label),
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Text(amount,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
