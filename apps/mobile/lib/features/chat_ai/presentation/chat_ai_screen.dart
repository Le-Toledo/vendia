import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text':
          'Olá! Sou o **Assistente VendeAI**. 🤖✨\n\nComo posso ajudar seu negócio hoje? Posso criar orçamentos, minutas de contrato, mensagens de cobrança para WhatsApp ou tirar dúvidas financeiras.',
    },
  ];

  bool _isTyping = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isTyping = true;
      _messageController.clear();
    });

    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1000));

    final lower = text.toLowerCase();
    String responseText =
        'Analisei seu pedido: "$text". Gostaria que eu salvasse esta ação diretamente nos seus módulos do VendeAI?';

    if (lower.contains('orçamento') || lower.contains('orcamento')) {
      responseText =
          '📋 **Orçamento Gerado com Sucesso!**\n\n**Cliente:** Empresa Exemplo Ltda\n1. Serviço de TI: R\$ 2.500,00\n2. Suporte Técnico: R\$ 500,00\n\n**Total:** R\$ 3.000,00\n\n*Clique no botão abaixo para gerar o PDF ou enviar por WhatsApp!*';
    } else if (lower.contains('contrato')) {
      responseText =
          '📜 **Minuta de Contrato Gerada por IA:**\n\n"Pelo presente instrumento, o CONTRATADO compromete-se a fornecer os serviços acordados via orçamento no valor de R\$ 3.000,00 em até 30 dias..."';
    } else if (lower.contains('cobrança') ||
        lower.contains('cobranca') ||
        lower.contains('whatsapp')) {
      responseText =
          '💬 *Mensagem para WhatsApp:*\n\n"Olá! Tudo bem? Passando para avisar que sua fatura vence em breve. Se precisar do código PIX, estou à disposição! 😊"';
    }

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({'sender': 'ai', 'text': responseText});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chat IA VendeAI',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Online • Provedor AIProvider',
                    style: TextStyle(fontSize: 11, color: AppColors.income)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Prompt Suggestions Horizontal List
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildPromptChip('📋 Criar Orçamento'),
                _buildPromptChip('📜 Criar Contrato'),
                _buildPromptChip('💬 Cobrança WhatsApp'),
                _buildPromptChip('📲 Post Instagram'),
                _buildPromptChip('🛒 Descrição Mercado Livre'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8),
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: SelectableText(
                        msg['text']!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isUser ? AppColors.primary : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('VendeAI está digitando...',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              border:
                  const Border(top: BorderSide(color: Colors.grey, width: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Pergunte à IA ou digite uma instrução...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12)),
        onPressed: () => _sendMessage(text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
