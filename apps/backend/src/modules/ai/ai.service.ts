import { Injectable, Logger, NotFoundException, ForbiddenException } from '@nestjs/common';
import { AIProvider } from './providers/ai-provider.interface';
import { PRIVACY_VERSION } from '../app-info/privacy';
import { MockAIProvider } from './providers/mock.provider';
import { OpenAIProvider } from './providers/openai.provider';
import { ChatAiDto, GenerateMarketingCopyDto } from './dto/ai-request.dto';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../common/prisma/prisma.service';
import { GeminiProvider } from './providers/gemini.provider';
import { GroqProvider } from './providers/groq.provider';

@Injectable()
export class AIService {
  private provider: AIProvider;
  private providerId: string;
  private readonly logger = new Logger(AIService.name);

  constructor(
    private readonly mockProvider: MockAIProvider,
    private readonly openAiProvider: OpenAIProvider,
    private readonly geminiProvider: GeminiProvider,
    private readonly groqProvider: GroqProvider,
    config: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    // Select active provider from environment variable
    const selectedProvider = config.get<string>('AI_PROVIDER', 'mock');
    this.providerId = selectedProvider;
    if (selectedProvider === 'openai') {
      this.provider = this.openAiProvider;
    } else if (selectedProvider === 'gemini') {
      this.provider = this.geminiProvider;
    } else if (selectedProvider === 'groq') {
      this.provider = this.groqProvider;
    } else {
      this.provider = this.mockProvider;
    }
    this.logger.log(`🤖 AI Engine inicializada com Provedor: ${this.provider.name}`);
  }

  private async requireConsent(userId: string) {
    const settings = await this.prisma.setting.findUnique({ where: { userId } });
    if (
      settings?.aiConsentVersion !== PRIVACY_VERSION ||
      settings.aiConsentProvider !== this.providerId ||
      !settings.aiConsentAt
    ) {
      throw new ForbiddenException('Autorize o envio ao provedor de IA antes de continuar.');
    }
  }

  async processChatMessage(userId: string, dto: ChatAiDto) {
    await this.requireConsent(userId);
    if (dto.clientId) {
      const client = await this.prisma.client.findFirst({
        where: { id: dto.clientId, userId },
        select: { id: true },
      });
      if (!client) throw new NotFoundException('Cliente não encontrado');
    }
    return this.provider.generateText(dto.message, { clientId: dto.clientId });
  }

  async generateMarketingCopy(userId: string, dto: GenerateMarketingCopyDto) {
    await this.requireConsent(userId);
    const prompt = `Crie uma mensagem/descrição de alta conversão para o canal "${dto.targetChannel}" referente ao produto/serviço "${dto.productOrService}". Detalhes adicionais: ${dto.details || 'Nenhum'}`;
    return this.provider.generateText(prompt);
  }
}
