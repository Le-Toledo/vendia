import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _clients = [
    {
      'id': '1',
      'name': 'Empresa Exemplo Ltda',
      'company': 'Exemplo Digital',
      'phone': '(11) 97777-8888',
      'email': 'contato@exemplodigital.com',
      'cpfCnpj': '98.765.432/0001-10',
    },
    {
      'id': '2',
      'name': 'Juliana Alencar',
      'company': 'Alencar Arquitetura',
      'phone': '(21) 99888-1122',
      'email': 'juliana@alencar.com.br',
      'cpfCnpj': '123.456.789-00',
    },
    {
      'id': '3',
      'name': 'Padaria & Confeitaria Solar',
      'company': 'Solar Alimentos',
      'phone': '(31) 98765-4321',
      'email': 'solar@padaria.com',
      'cpfCnpj': '45.678.901/0001-55',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes Cadastrados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded,
                color: AppColors.primary),
            onPressed: () => context.push('/clients/new'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome, empresa, CPF/CNPJ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _searchController.clear()),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Client List
            Expanded(
              child: ListView.builder(
                itemCount: _clients.length,
                itemBuilder: (context, index) {
                  final client = _clients[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      onTap: () => context.push('/clients/edit', extra: client),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              client['name']![0].toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client['name']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  client['company']!,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined,
                                        size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(client['phone']!,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/clients/new'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Cliente',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
