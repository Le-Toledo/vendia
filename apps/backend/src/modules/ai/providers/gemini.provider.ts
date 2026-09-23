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
export class GeminiProvider implements AIProvider {
  readonly name = 'Google Gemini Provider';
  private readonly logger = new Logger(GeminiProvider.name);

  constructor(private readonly config: ConfigService) {}

  async generateText(prompt: string, _context?: Record<string, any>): Promise<AIResponse> {
    const apiKey = this.config.get<string>('GEMINI_API_KEY');

    if (!apiKey) {
      throw new ServiceUnavailableException('Serviço de IA não configurado');
    }

    const model = this.config.get<string>('GEMINI_MODEL', 'gemini-2.5-flash');

    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;

    for (let attempt = 0; attempt < 3; attempt += 1) {
      try {
        const response = await fetch(url, {
          method: 'POST',
          signal: AbortSignal.timeout(15_000),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: JSON.stringify({
            system_instruction: {
              parts: [
                {
                  text: 'Você é o assistente do VendAI. Responda em português do Brasil com foco em pequenos negócios, orçamentos, contratos e comunicação comercial.',
                },
              ],
            },
            contents: [
              {
                role: 'user',
                parts: [{ text: prompt }],
              },
            ],
            generationConfig: {
              temperature: 0.7,
            },
          }),
        });

        if (response.status === 401 || response.status === 403) {
          this.logger.error('Gemini rejected configured credentials');
          throw new ServiceUnavailableException('Serviço de IA indisponível');
        }

        if ((response.status === 429 || response.status >= 500) && attempt < 2) {
          await new Promise((resolve) => setTimeout(resolve, 250 * 2 ** attempt));
          continue;
        }

        if (!response.ok) {
          this.logger.error(`Gemini returned HTTP ${response.status}`);
          throw new BadGatewayException('Falha ao processar solicitação de IA');
        }

        return {
          content: this.extractContent(await response.json()),
          actionType: 'none',
        };
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
          this.logger.error('Gemini request failed after retries');
          throw new BadGatewayException('Falha ao conectar ao serviço de IA');
        }
      }
    }

    throw new BadGatewayException('Falha ao conectar ao serviço de IA');
  }

  private extractContent(data: unknown): string {
    if (!data || typeof data !== 'object') {
      throw new BadGatewayException('Resposta inválida do serviço de IA');
    }

    const candidates = (
      data as {
        candidates?: Array<{
          content?: {
            parts?: Array<{ text?: unknown }>;
          };
        }>;
      }
    ).candidates;

    const text = candidates?.[0]?.content?.parts
      ?.map((part) => part.text)
      .filter((part): part is string => typeof part === 'string')
      .join('')
      .trim();

    if (!text) {
      throw new BadGatewayException('Resposta vazia do serviço de IA');
    }

    return text;
  }
}
