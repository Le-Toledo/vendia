import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _themeMode = 'Escuro (Dark)';
  final String _language = 'Português (Brasil)';
  String _aiProvider = 'OpenAI (GPT-4o)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações & Preferências'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Aparência e Tema',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Modo de Exibição'),
                  subtitle: Text(_themeMode),
                  leading: const Icon(Icons.dark_mode_outlined,
                      color: AppColors.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    setState(() {
                      _themeMode = _themeMode.contains('Dark')
                          ? 'Claro (Light)'
                          : 'Escuro (Dark)';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inteligência Artificial (AIProvider)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Provedor Ativo de IA'),
                  subtitle: Text(_aiProvider),
                  leading:
                      const Icon(Icons.auto_awesome, color: AppColors.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Escolher Provedor de IA'),
                        children: [
                          'OpenAI (GPT-4o)',
                          'Google Gemini 1.5',
                          'Anthropic Claude 3',
                          'Mock AI (Local)'
                        ]
                            .map((p) => SimpleDialogOption(
                                  onPressed: () {
                                    setState(() => _aiProvider = p);
                                    Navigator.pop(context);
                                  },
                                  child: Text(p),
                                ))
                            .toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Idioma e Região',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Idioma do Sistema'),
                  subtitle: Text(_language),
                  leading: const Icon(Icons.language, color: AppColors.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
