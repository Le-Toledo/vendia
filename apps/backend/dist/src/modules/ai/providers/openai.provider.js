"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var OpenAIProvider_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.OpenAIProvider = void 0;
const common_1 = require("@nestjs/common");
let OpenAIProvider = OpenAIProvider_1 = class OpenAIProvider {
    constructor() {
        this.name = 'OpenAI GPT-4o Provider';
        this.logger = new common_1.Logger(OpenAIProvider_1.name);
    }
    async generateText(prompt, context) {
        const apiKey = process.env.OPENAI_API_KEY;
        if (!apiKey) {
            this.logger.warn('Chave OPENAI_API_KEY não configurada. Fallback para MockAIProvider.');
            return {
                content: `[OpenAI Simulated]: Resposta para "${prompt}". Configure a variável OPENAI_API_KEY no arquivo .env para respostas reais da OpenAI.`,
                actionType: 'none',
            };
        }
        try {
            const response = await fetch('https://api.openai.com/v1/chat/completions', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${apiKey}`,
                },
                body: JSON.stringify({
                    model: 'gpt-4o-mini',
                    messages: [
                        {
                            role: 'system',
                            content: 'Você é o assistente inteligente do aplicativo VendeAI. Responda em português do Brasil com foco em pequenos negócios, orçamentos, contratos e copys comerciais.',
                        },
                        { role: 'user', content: prompt },
                    ],
                    temperature: 0.7,
                }),
            });
            const data = await response.json();
            const content = data.choices?.[0]?.message?.content || 'Não foi possível obter resposta da IA.';
            return { content, actionType: 'none' };
        }
        catch (error) {
            this.logger.error('Erro ao chamar OpenAI API:', error);
            return {
                content: 'Desculpe, ocorreu uma falha ao conectar à OpenAI. Tente novamente mais tarde.',
                actionType: 'none',
            };
        }
    }
};
exports.OpenAIProvider = OpenAIProvider;
exports.OpenAIProvider = OpenAIProvider = OpenAIProvider_1 = __decorate([
    (0, common_1.Injectable)()
], OpenAIProvider);
//# sourceMappingURL=openai.provider.js.map