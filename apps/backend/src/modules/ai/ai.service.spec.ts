import { Test, TestingModule } from '@nestjs/testing';
import { AIService } from './ai.service';
import { MockAIProvider } from './providers/mock.provider';
import { OpenAIProvider } from './providers/openai.provider';

describe('AIService', () => {
  let service: AIService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AIService, MockAIProvider, OpenAIProvider],
    }).compile();

    service = module.get<AIService>(AIService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should process chat message and return AIResponse', async () => {
    const result = await service.processChatMessage({
      message: 'Crie um orçamento de desenvolvimento de app no valor de R$ 3000',
    });

    expect(result).toBeDefined();
    expect(result.content).toBeDefined();
    expect(result.actionType).toBe('create_quote');
    expect(result.structuredData?.items.length).toBeGreaterThan(0);
  });

  it('should generate marketing copy for Instagram', async () => {
    const result = await service.generateMarketingCopy({
      targetChannel: 'Instagram',
      productOrService: 'Consultoria Financeira MEI',
    });

    expect(result).toBeDefined();
    expect(result.content).toContain('VendeAI');
  });
});
