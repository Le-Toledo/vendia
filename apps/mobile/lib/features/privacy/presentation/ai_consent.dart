import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_providers.dart';
import 'privacy_screen.dart';

Future<bool> ensureAiConsent(BuildContext context, WidgetRef ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final configResponse = await api.dio.get('/app/config');
    final ai =
        api.unwrap<Map<String, dynamic>>(configResponse)['ai']
            as Map<String, dynamic>;
    final profileResponse = await api.dio.get('/users/me');
    final settings =
        api.unwrap<Map<String, dynamic>>(profileResponse)['settings']
            as Map<String, dynamic>?;
    if (!context.mounted) return false;
    if (settings?['aiConsentVersion'] == ai['consentVersion'] &&
        settings?['aiConsentProvider'] == ai['id'] &&
        settings?['aiConsentAt'] != null) {
      return true;
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Autorizar uso de IA'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para responder ao chat e gerar textos de marketing, o VendAI enviará os textos que você informar ao provedor ${ai['name']}. Isso pode incluir dados pessoais presentes no texto e processamento fora do Brasil. Não envie senhas ou dados sensíveis. Você pode recusar e continuar usando a gestão do negócio, ou revogar a autorização em Configurações.',
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyScreen(),
                  ),
                ),
                child: const Text('Ler política de privacidade'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Autorizar envio'),
          ),
        ],
      ),
    );
    if (accepted != true || !context.mounted) return false;
    await api.dio.put(
      '/users/ai-consent',
      data: {
        'approved': true,
        'version': ai['consentVersion'],
        'provider': ai['id'],
      },
    );
    return context.mounted;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível verificar a autorização de IA. Tente novamente.',
          ),
        ),
      );
    }
    return false;
  }
}
