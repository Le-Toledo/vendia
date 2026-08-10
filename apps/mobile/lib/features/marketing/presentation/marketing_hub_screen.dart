import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/glass_card.dart';

class MarketingHubScreen extends StatefulWidget {
  const MarketingHubScreen({super.key});

  @override
  State<MarketingHubScreen> createState() => _MarketingHubScreenState();
}

class _MarketingHubScreenState extends State<MarketingHubScreen> {
  String _selectedChannel = 'Instagram';
  final _productController = TextEditingController();
  final _detailsController = TextEditingController();

  bool _isGenerating = false;
  String? _generatedCopy;

  final List<String> _channels = [
    'Instagram',
    'Facebook',
    'WhatsApp Cobrança',
    'Mercado Livre',
    'Shopee',
    'Amazon',
    'Anúncios Google/Meta',
  ];

  void _onGenerate() async {
    if (_productController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do produto ou serviço')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedCopy = null;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _isGenerating = false;
      _generatedCopy = '''
🚀 **ALERTA DE OFERTA EXCLUSIVA!**

Diga adeus às dores de cabeça com **${_productController.text}**! 

Nossa solução foi desenvolvida especialmente para autônomos e pequenos empreendedores que buscam máxima qualidade, rapidez e excelente custo-benefício.

✨ **Por que escolher nossa solução?**
- Envio Rápido e Atendimento Personalizado
- Garantia de Satisfação e Suporte Dedicado
- Condições Especiais de Pagamento via PIX em até 12x

📦 *Poucas unidades disponíveis nesta condição!*

👉 **Clique no link da Bio e solicite seu orçamento agora mesmo pelo WhatsApp!**

#${_selectedChannel.replaceAll(' ', '')} #${_productController.text.replaceAll(' ', '')} #VendeAI #OfertaImperdivel
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketing & E-commerce Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gerador Inteligente de Anúncios e Copys ⚡',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Crie legendas e descrições para e-commerce em segundos utilizando IA.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Channel Selection Chips
            const Text('Selecione o Canal / Plataforma:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _channels.map((channel) {
                final isSelected = _selectedChannel == channel;
                return ChoiceChip(
                  label: Text(channel),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.bold),
                  onSelected: (val) {
                    if (val) setState(() => _selectedChannel = channel);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'Produto ou Serviço *',
              hint: 'Ex: Assistência Técnica de Celulares e Notebooks',
              controller: _productController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Detalhes / Promoção (Opcional)',
              hint: 'Ex: 20% de desconto na primeira manutenção',
              controller: _detailsController,
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Gerar Copy com IA',
              icon: Icons.auto_awesome,
              isLoading: _isGenerating,
              onPressed: _onGenerate,
            ),

            if (_generatedCopy != null) ...[
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('Resultado Gerado:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Texto copiado para a área de transferência!')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copiar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _generatedCopy!,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
