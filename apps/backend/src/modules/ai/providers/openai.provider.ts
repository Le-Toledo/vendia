import { Injectable, Logger } from '@nestjs/common';
import { AIProvider, AIResponse } from './ai-provider.interface';

@Injectable()
export class OpenAIProvider implements AIProvider {
  readonly name = 'OpenAI GPT-4o Provider';
  private readonly logger = new Logger(OpenAIProvider.name);

  async generateText(prompt: string, context?: Record<string, any>): Promise<AIResponse> {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      this.logger.warn('Chave OPENAI_API_KEY não configurada. Fallback para MockAIProvider.');
      return {
        content: `[OpenAI Simulated]: Resposta para "${prompt}". Configure a variável OPENAI_API_KEY no arquivo .env para respostas reais da OpenAI.`,
        actionType: 'none',
      };
    }

    try {
      // Direct HTTP call to OpenAI API to avoid heavy SDK dependencies
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
              content:
                'Você é o assistente inteligente do aplicativo VendeAI. Responda em português do Brasil com foco em pequenos negócios, orçamentos, contratos e copys comerciais.',
            },
            { role: 'user', content: prompt },
          ],
          temperature: 0.7,
        }),
      });

      const data = await response.json();
      const content = data.choices?.[0]?.message?.content || 'Não foi possível obter resposta da IA.';

      return { content, actionType: 'none' };
    } catch (error) {
      this.logger.error('Erro ao chamar OpenAI API:', error);
      return {
        content: 'Desculpe, ocorreu uma falha ao conectar à OpenAI. Tente novamente mais tarde.',
        actionType: 'none',
      };
    }
  }
}
