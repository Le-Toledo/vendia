import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_providers.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});
  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  late Future<Map<String, dynamic>> _policy;
  @override
  void initState() {
    super.initState();
    _policy = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final api = ref.read(apiClientProvider);
    final response = await api.dio.get('/app/config');
    return api.unwrap<Map<String, dynamic>>(response)['privacy']
        as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacidade')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _policy,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: () => setState(() => _policy = _load()),
              child: const Text(
                'Não foi possível carregar a política. Tentar novamente',
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final policy = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              policy['title'] as String,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('Versão ${policy['version']}'),
            for (final section in policy['sections'] as List) ...[
              const SizedBox(height: 24),
              Text(
                section['title'] as String,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(section['text'] as String),
            ],
          ],
        );
      },
    ),
  );
}
