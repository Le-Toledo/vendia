"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var MockAIProvider_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.MockAIProvider = void 0;
const common_1 = require("@nestjs/common");
let MockAIProvider = MockAIProvider_1 = class MockAIProvider {
    constructor() {
        this.name = 'Mock AI Engine (Dev)';
        this.logger = new common_1.Logger(MockAIProvider_1.name);
    }
    async generateText(prompt, context) {
        this.logger.log(`[MockAI] Executando prompt com contexto: ${prompt.slice(0, 50)}...`);
        const lowerPrompt = prompt.toLowerCase();
        if (lowerPrompt.includes('orçamento') || lowerPrompt.includes('orcamento') || lowerPrompt.includes('proposta')) {
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
        if (lowerPrompt.includes('whatsapp') || lowerPrompt.includes('cobrança') || lowerPrompt.includes('cobranca')) {
            return {
                content: `💬 *Mensagem para WhatsApp (Cobrança Amigável):*\n\n"Olá [Nome do Cliente], tudo bem? 😊\nPassando para lembrar que o pagamento da parcela referente aos serviços prestados vence em breve.\n\nCaso já tenha efetuado o pagamento, por gentileza desconsidere esta mensagem. Se precisar do código PIX novamente, estou à disposição!"`,
                actionType: 'create_copy',
            };
        }
        if (lowerPrompt.includes('instagram') ||
            lowerPrompt.includes('facebook') ||
            lowerPrompt.includes('mercado livre') ||
            lowerPrompt.includes('shopee') ||
            lowerPrompt.includes('amazon') ||
            lowerPrompt.includes('anúncio') ||
            lowerPrompt.includes('post')) {
            return {
                content: `✨ *Copy e Descrição de Alta Conversão:* \n\n🚀 **Transforme sua rotina com qualidade profissional!**\n\nIdeal para quem busca máxima eficiência e excelente custo-benefício. Garanta já o seu com envio rápido para todo o Brasil! 📦⚡\n\n👉 *Clique no link da bio e faça seu pedido hoje!*\n\n#VendeAI #Empreendedorismo #AltaQualidade #OfertaImperdivel`,
                actionType: 'create_copy',
            };
        }
        return {
            content: `Olá! Sou o **Assistente VendeAI**. 🚀\n\nAnalisei sua solicitação: "${prompt}".\nComo posso ajudar seu negócio hoje? Posso gerar orçamentos, minutas de contrato, copys para Instagram/Mercado Livre ou mensagens de cobrança para WhatsApp em segundos!`,
            actionType: 'none',
        };
    }
};
exports.MockAIProvider = MockAIProvider;
exports.MockAIProvider = MockAIProvider = MockAIProvider_1 = __decorate([
    (0, common_1.Injectable)()
], MockAIProvider);
//# sourceMappingURL=mock.provider.js.map