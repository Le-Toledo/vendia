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
export class GroqProvider implements AIProvider {
  readonly name = 'Groq Provider';
  private readonly logger = new Logger(GroqProvider.name);

  constructor(private readonly config: ConfigService) {}

  async generateText(prompt: string, _context?: Record<string, any>): Promise<AIResponse> {
    const apiKey = this.config.get<string>('GROQ_API_KEY');

    if (!apiKey) {
      throw new ServiceUnavailableException('Serviço de IA não configurado');
    }

    const model = this.config.get<string>('GROQ_MODEL', 'llama-3.3-70b-versatile');

    try {
      const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        signal: AbortSignal.timeout(15_000),
        headers: {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model,
          messages: [
            {
              role: 'system',
              content:
                'Você é o assistente do VendAI. Responda em português do Brasil com foco em pequenos negócios, orçamentos, contratos e comunicação comercial.',
            },
            {
              role: 'user',
              content: prompt,
            },
          ],
          temperature: 0.7,
        }),
      });

      if (response.status === 401 || response.status === 403) {
        this.logger.error('Groq rejeitou as credenciais configuradas');
        throw new ServiceUnavailableException('Serviço de IA indisponível');
      }

      if (!response.ok) {
        this.logger.error(`Groq retornou HTTP ${response.status}`);
        throw new BadGatewayException('Falha ao processar solicitação de IA');
      }

      const data = (await response.json()) as {
        choices?: Array<{
          message?: {
            content?: string;
          };
        }>;
      };

      const content = data.choices?.[0]?.message?.content?.trim();

      if (!content) {
        throw new BadGatewayException('Resposta vazia do serviço de IA');
      }

      return {
        content,
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

      this.logger.error('Falha na comunicação com Groq');
      throw new BadGatewayException('Falha ao conectar ao serviço de IA');
    }
  }
}
