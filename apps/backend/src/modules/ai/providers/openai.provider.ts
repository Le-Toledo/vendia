import {
  BadGatewayException,
  GatewayTimeoutException,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AIProvider, AIResponse } from './ai-provider.interface';

@Injectable()
export class OpenAIProvider implements AIProvider {
  readonly name = 'OpenAI Provider';
  private readonly logger = new Logger(OpenAIProvider.name);

  constructor(private readonly config: ConfigService) {}

  async generateText(prompt: string, _context?: Record<string, any>): Promise<AIResponse> {
    const apiKey = this.config.get<string>('OPENAI_API_KEY');
    if (!apiKey) throw new ServiceUnavailableException('Serviço de IA não configurado');

    for (let attempt = 0; attempt < 3; attempt += 1) {
      try {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
          method: 'POST',
          signal: AbortSignal.timeout(15_000),
          headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${apiKey}` },
          body: JSON.stringify({
            model: this.config.get<string>('OPENAI_MODEL', 'gpt-4o-mini'),
            messages: [
              {
                role: 'system',
                content:
                  'Você é o assistente do VendeAI. Responda em português do Brasil com foco em pequenos negócios, orçamentos, contratos e comunicação comercial.',
              },
              { role: 'user', content: prompt },
            ],
            temperature: 0.7,
          }),
        });

        if (response.status === 401 || response.status === 403) {
          this.logger.error('OpenAI rejected configured credentials');
          throw new ServiceUnavailableException('Serviço de IA indisponível');
        }
        if ((response.status === 429 || response.status >= 500) && attempt < 2) {
          await new Promise((resolve) => setTimeout(resolve, 250 * 2 ** attempt));
          continue;
        }
        if (!response.ok) throw new BadGatewayException('Falha ao processar solicitação de IA');
        return { content: this.extractContent(await response.json()), actionType: 'none' };
      } catch (error) {
        if (error instanceof ServiceUnavailableException || error instanceof BadGatewayException) {
          throw error;
        }
        if (
          error instanceof Error &&
          (error.name === 'TimeoutError' || error.name === 'AbortError')
        ) {
          throw new GatewayTimeoutException('Tempo limite excedido no serviço de IA');
        }
        if (attempt === 2) {
          this.logger.error('OpenAI request failed after retries');
          throw new BadGatewayException('Falha ao conectar ao serviço de IA');
        }
      }
    }
    throw new BadGatewayException('Falha ao conectar ao serviço de IA');
  }

  private extractContent(data: unknown): string {
    if (!data || typeof data !== 'object')
      throw new BadGatewayException('Resposta inválida do serviço de IA');
    const choices = (data as { choices?: unknown }).choices;
    if (!Array.isArray(choices))
      throw new BadGatewayException('Resposta inválida do serviço de IA');
    const content = (choices[0] as { message?: { content?: unknown } } | undefined)?.message
      ?.content;
    if (typeof content !== 'string' || !content.trim())
      throw new BadGatewayException('Resposta vazia do serviço de IA');
    return content;
  }
}
