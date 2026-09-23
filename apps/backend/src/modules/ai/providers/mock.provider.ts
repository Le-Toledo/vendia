import { Injectable, Logger } from '@nestjs/common';
import { AIProvider, AIResponse } from './ai-provider.interface';

@Injectable()
export class MockAIProvider implements AIProvider {
  readonly name = 'Mock AI Engine (Dev)';
  private readonly logger = new Logger(MockAIProvider.name);

  async generateText(prompt: string, _context?: Record<string, any>): Promise<AIResponse> {
    this.logger.log(`[MockAI] Executando prompt com contexto: ${prompt.slice(0, 50)}...`);

    const lowerPrompt = prompt.toLowerCase();

    // 1. Orçamento / Proposta Comercial
    if (
      lowerPrompt.includes('orçamento') ||
      lowerPrompt.includes('orcamento') ||
      lowerPrompt.includes('proposta')
    ) {
      return {
        content: `### 📋 Proposta & Orçamento Gerado por IA\n\n**Projeto:** Serviços de Gestão e Tecnologia\n\n1. **Desenvolvimento de Solução / Serviço:** R$ 2.500,00\n2. **Suporte & Configuração Inicial:** R$ 500,00\n\n**Total:** R$ 3.000,00 (Condições: 50% de entrada + 50% na entrega).\n\n*Clique no botão abaixo para transformar esta resposta em um orçamento oficial no VendeAI!*`,
        actionType: 'create_quote',
        structuredData: {
          items: [
            { description: 'Desenvolvimento de Solução / Serviço', quantity: 1, unitPrice: 2500.0 },
            { description: 'Suporte & Configuração Inicial', quantity: 1, unitPrice: 500.0 },
          ],
          discount: 0,
        },
      };
    }

    // 2. Contrato
    if (lowerPrompt.includes('contrato')) {
      return {
        content: `### 📜 Minuta de Contrato Comercial Gerada por IA\n\n**CLÁUSULA PRIMEIRA - DO OBJETO:** O presente contrato tem por objeto a prestação de serviços especificados na proposta comercial aceite pelo CONTRATANTE.\n\n**CLÁUSULA SEGUNDA - DO VALOR E PAGAMENTO:** Pela prestação dos serviços objeto deste instrumento, o CONTRATANTE pagará ao CONTRATADO a quantia pactuada via PIX ou boleto bancário.\n\n**CLÁUSULA TERCEIRA - DA RESCISÃO:** O presente contrato poderá ser rescindido por ambas as partes mediante aviso prévio por escrito com 15 dias de antecedência.`,
        actionType: 'create_contract',
        structuredData: {
          title: 'Contrato de Prestação de Serviços',
          value: 3000.0,
        },
      };
    }

    // 3. WhatsApp / Cobrança
    if (
      lowerPrompt.includes('whatsapp') ||
      lowerPrompt.includes('cobrança') ||
      lowerPrompt.includes('cobranca')
    ) {
      return {
        content: `💬 *Mensagem para WhatsApp (Cobrança Amigável):*\n\n"Olá [Nome do Cliente], tudo bem? 😊\nPassando para lembrar que o pagamento da parcela referente aos serviços prestados vence em breve.\n\nCaso já tenha efetuado o pagamento, por gentileza desconsidere esta mensagem. Se precisar do código PIX novamente, estou à disposição!"`,
        actionType: 'create_copy',
      };
    }

    // 4. Redes Sociais / E-commerce (Instagram, Mercado Livre, Shopee, Amazon)
    if (
      lowerPrompt.includes('instagram') ||
      lowerPrompt.includes('facebook') ||
      lowerPrompt.includes('mercado livre') ||
      lowerPrompt.includes('shopee') ||
      lowerPrompt.includes('amazon') ||
      lowerPrompt.includes('anúncio') ||
      lowerPrompt.includes('post')
    ) {
      return {
        content: `✨ *Copy e Descrição de Alta Conversão:* \n\n🚀 **Transforme sua rotina com qualidade profissional!**\n\nIdeal para quem busca máxima eficiência e excelente custo-benefício. Garanta já o seu com envio rápido para todo o Brasil! 📦⚡\n\n👉 *Clique no link da bio e faça seu pedido hoje!*\n\n#VendeAI #Empreendedorismo #AltaQualidade #OfertaImperdivel`,
        actionType: 'create_copy',
      };
    }

    // 5. Perguntas Financeiras e Comerciais Padrão
    return {
      content: `Olá! Sou o **Assistente VendeAI**. 🚀\n\nAnalisei sua solicitação: "${prompt}".\nComo posso ajudar seu negócio hoje? Posso gerar orçamentos, minutas de contrato, copys para Instagram/Mercado Livre ou mensagens de cobrança para WhatsApp em segundos!`,
      actionType: 'none',
    };
  }
}
