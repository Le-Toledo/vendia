import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/business_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/application/auth_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    // The router redirects asynchronously; never render the prior account in
    // the frame between session invalidation and navigation to login.
    if (user == null) return const SizedBox.shrink();
    final summary = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VendAI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(dashboardProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Olá, ${user.name} 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user.companyName ?? 'Visão geral do seu negócio',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            summary.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => GlassCard(
                child: Column(
                  children: [
                    Text(error.toString()),
                    TextButton(
                      onPressed: () => ref.invalidate(dashboardProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (data) {
                final financial = data['financial'] as Map<String, dynamic>;
                final metrics = data['metrics'] as Map<String, dynamic>;
                double money(String key) =>
                    double.parse(financial[key].toString());
                return Column(
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saldo atual',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            Formatters.currency(money('balance')),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _Money(
                                  label: 'Receitas',
                                  value: money('totalIncome'),
                                  color: AppColors.income,
                                ),
                              ),
                              Expanded(
                                child: _Money(
                                  label: 'Despesas',
                                  value: money('totalExpense'),
                                  color: AppColors.expense,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            label: 'Clientes',
                            value: metrics['clientCount'].toString(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _Metric(
                            label: 'Orçamentos',
                            value: metrics['quoteCount'].toString(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _Metric(
                            label: 'Contratos',
                            value: metrics['contractCount'].toString(),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Acessos rápidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                _Action(
                  label: 'Clientes',
                  icon: Icons.people_outline,
                  route: '/clients',
                ),
                _Action(
                  label: 'Orçamentos',
                  icon: Icons.request_quote_outlined,
                  route: '/quotes',
                ),
                _Action(
                  label: 'Contratos',
                  icon: Icons.description_outlined,
                  route: '/contracts',
                ),
                _Action(
                  label: 'Finanças',
                  icon: Icons.account_balance_wallet_outlined,
                  route: '/finance',
                ),
                _Action(
                  label: 'Assistente IA',
                  icon: Icons.auto_awesome,
                  route: '/chat-ai',
                ),
                _Action(
                  label: 'Marketing',
                  icon: Icons.campaign_outlined,
                  route: '/marketing',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Money extends StatelessWidget {
  const _Money({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey)),
      Text(
        Formatters.currency(value),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    ),
  );
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.icon, required this.route});
  final String label;
  final IconData icon;
  final String route;
  @override
  Widget build(BuildContext context) => GlassCard(
    onTap: () => context.push(route),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
