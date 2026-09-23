import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/business_providers.dart';
import '../../../core/widgets/glass_card.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});
  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes Cadastrados'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.primary,
            ),
            onPressed: () async {
              await context.push('/clients/new');
              ref.invalidate(clientsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: search,
              decoration: const InputDecoration(
                hintText: 'Pesquisar por nome ou empresa...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: clients.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: FilledButton(
                  onPressed: () => ref.invalidate(clientsProvider),
                  child: Text(
                    'Tentar novamente\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (items) {
                final term = search.text.toLowerCase();
                final filtered = items
                    .where(
                      (c) => '${c['name']} ${c['companyName'] ?? ''}'
                          .toLowerCase()
                          .contains(term),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Nenhum cliente encontrado.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(clientsProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final client = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          onTap: () async {
                            await context.push('/clients/edit', extra: client);
                            ref.invalidate(clientsProvider);
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: .15,
                              ),
                              child: Text(
                                (client['name'] as String)
                                    .substring(0, 1)
                                    .toUpperCase(),
                              ),
                            ),
                            title: Text(
                              client['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              [
                                    client['companyName'],
                                    client['email'],
                                    client['phone'],
                                  ]
                                  .whereType<String>()
                                  .where((v) => v.isNotEmpty)
                                  .join(' • '),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
