import { Test, TestingModule } from '@nestjs/testing';
import { GeminiProvider } from './providers/gemini.provider';
import { GroqProvider } from './providers/groq.provider';
import { PRIVACY_VERSION } from '../app-info/privacy';
import { AIService } from './ai.service';
import { MockAIProvider } from './providers/mock.provider';
import { OpenAIProvider } from './providers/openai.provider';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../common/prisma/prisma.service';

describe('AIService', () => {
  let service: AIService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AIService,
        GeminiProvider,
        GroqProvider,
        MockAIProvider,
        OpenAIProvider,
        {
          provide: ConfigService,
          useValue: { get: (_key: string, fallback?: string) => fallback ?? 'mock' },
        },
        {
          provide: PrismaService,
          useValue: {
            client: { findFirst: jest.fn() },
            setting: {
              findUnique: jest.fn().mockResolvedValue({
                aiConsentVersion: PRIVACY_VERSION,
                aiConsentProvider: 'mock',
                aiConsentAt: new Date(),
              }),
            },
          },
        },
      ],
    }).compile();

    service = module.get<AIService>(AIService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should process chat message and return AIResponse', async () => {
    const result = await service.processChatMessage('user-1', {
      message: 'Crie um orçamento de desenvolvimento de app no valor de R$ 3000',
    });

    expect(result).toBeDefined();
    expect(result.content).toBeDefined();
    expect(result.actionType).toBe('create_quote');
    expect(result.structuredData?.items.length).toBeGreaterThan(0);
  });

  it('should generate marketing copy for Instagram', async () => {
    const result = await service.generateMarketingCopy('user-1', {
      targetChannel: 'Instagram',
      productOrService: 'Consultoria Financeira MEI',
    });

    expect(result).toBeDefined();
    expect(result.content).toContain('VendeAI');
  });
});
