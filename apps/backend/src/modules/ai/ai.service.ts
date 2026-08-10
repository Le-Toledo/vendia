import { Injectable, Logger } from '@nestjs/common';
import { AIProvider } from './providers/ai-provider.interface';
import { MockAIProvider } from './providers/mock.provider';
import { OpenAIProvider } from './providers/openai.provider';
import { ChatAiDto, GenerateMarketingCopyDto } from './dto/ai-request.dto';

@Injectable()
export class AIService {
  private provider: AIProvider;
  private readonly logger = new Logger(AIService.name);

  constructor(
    private readonly mockProvider: MockAIProvider,
    private readonly openAiProvider: OpenAIProvider,
  ) {
    // Select active provider from environment variable
    const selectedProvider = (process.env.AI_PROVIDER || 'mock').toLowerCase();
    if (selectedProvider === 'openai' && process.env.OPENAI_API_KEY) {
      this.provider = this.openAiProvider;
    } else {
      this.provider = this.mockProvider;
    }
    this.logger.log(`🤖 AI Engine inicializada com Provedor: ${this.provider.name}`);
  }

  async processChatMessage(dto: ChatAiDto) {
    return this.provider.generateText(dto.message, { clientId: dto.clientId });
  }

  async generateMarketingCopy(dto: GenerateMarketingCopyDto) {
    const prompt = `Crie uma mensagem/descrição de alta conversão para o canal "${dto.targetChannel}" referente ao produto/serviço "${dto.productOrService}". Detalhes adicionais: ${dto.details || 'Nenhum'}`;
    return this.provider.generateText(prompt);
  }
}
