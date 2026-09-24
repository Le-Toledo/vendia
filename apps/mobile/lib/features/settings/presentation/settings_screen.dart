import 'dart:convert';
import '../../privacy/presentation/privacy_screen.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_providers.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/application/auth_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _exporting = false;
  bool _deletingAccount = false;

  Future<void> _exportData() async {
    if (_exporting) return;

    setState(() => _exporting = true);

    try {
      final api = ref.read(apiClientProvider);
      final response = await api.dio.get('/users/export');

      final data = api.unwrap<Map<String, dynamic>>(response);

      final json = const JsonEncoder.withIndent('  ').convert(data);
      final bytes = Uint8List.fromList(utf8.encode(json));

      if (!mounted) return;

      final size = MediaQuery.sizeOf(context);

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'application/json',
              name: 'vendeai_meus_dados.json',
            ),
          ],
          title: 'Meus dados do VendAI',
          text: 'Exportação dos meus dados do VendAI.',
          sharePositionOrigin: Rect.fromCenter(
            center: size.center(Offset.zero),
            width: 1,
            height: 1,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      final message = ref.read(apiClientProvider).readableError(error).message;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    if (_deletingAccount) return;

    final controller = TextEditingController();
    bool canDelete = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Excluir minha conta?'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Esta ação é permanente. Seus dados serão excluídos e não poderão ser recuperados.',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Para confirmar, digite EXCLUIR abaixo:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Digite EXCLUIR',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          canDelete = value.trim() == 'EXCLUIR';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: canDelete
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  child: const Text('Excluir definitivamente'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (confirmed != true || !mounted) return;

    setState(() => _deletingAccount = true);

    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta excluída com sucesso.')),
      );
    } catch (error) {
      if (!mounted) return;

      final message = ref.read(apiClientProvider).readableError(error).message;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _deletingAccount = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aparência',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto),
                      label: Text('Sistema'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Claro'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Escuro'),
                    ),
                  ],
                  selected: {current},
                  showSelectedIcon: false,
                  onSelectionChanged: (value) => ref
                      .read(themeControllerProvider.notifier)
                      .setMode(value.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const GlassCard(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recursos inteligentes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                ListTile(
                  title: Text('Provedor configurado no servidor'),
                  subtitle: Text(
                    'O provedor de IA é gerenciado com segurança pelo servidor.',
                  ),
                  leading: Icon(Icons.auto_awesome, color: AppColors.primary),
                  onTap: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const GlassCard(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Idioma e Região',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                ListTile(
                  title: Text('Idioma e região'),
                  subtitle: Text('Português (Brasil) • Real brasileiro'),
                  leading: Icon(Icons.language, color: AppColors.primary),
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
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Política de privacidade'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacyScreen(),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: const Text('Revogar autorização de IA'),
                  subtitle: const Text(
                    'Impedir novos envios até autorizar novamente.',
                  ),
                  onTap: () async {
                    final api = ref.read(apiClientProvider);
                    try {
                      await api.dio.put(
                        '/users/ai-consent',
                        data: {'approved': false},
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Autorização de IA revogada.'),
                        ),
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Não foi possível revogar a autorização. Tente novamente.',
                          ),
                        ),
                      );
                    }
                  },
                ),
                const Text(
                  'Privacidade e dados',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.download_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Exportar meus dados'),
                  subtitle: const Text(
                    'Gere uma cópia dos dados armazenados na sua conta.',
                  ),
                  trailing: _exporting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _exporting ? null : _exportData,
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Excluir minha conta',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Exclua permanentemente sua conta e seus dados.',
                  ),
                  trailing: _deletingAccount
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _deletingAccount ? null : _confirmDeleteAccount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
