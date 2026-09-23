import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    ('/dashboard', 'Início', Icons.home_outlined, Icons.home),
    ('/clients', 'Clientes', Icons.people_outline, Icons.people),
    (
      '/quotes',
      'Orçamentos',
      Icons.request_quote_outlined,
      Icons.request_quote,
    ),
    (
      '/finance',
      'Financeiro',
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
    ),
    ('/contracts', 'Contratos', Icons.description_outlined, Icons.description),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selected = _destinations.indexWhere(
      (item) => location == item.$1 || location.startsWith('${item.$1}/'),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        onDestinationSelected: (index) => context.go(_destinations[index].$1),
        destinations: [
          for (final item in _destinations)
            NavigationDestination(
              icon: Icon(item.$3),
              selectedIcon: Icon(item.$4),
              label: item.$2,
            ),
        ],
      ),
    );
  }
}
