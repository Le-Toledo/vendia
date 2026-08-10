"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const ai_service_1 = require("./ai.service");
const mock_provider_1 = require("./providers/mock.provider");
const openai_provider_1 = require("./providers/openai.provider");
describe('AIService', () => {
    let service;
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            providers: [ai_service_1.AIService, mock_provider_1.MockAIProvider, openai_provider_1.OpenAIProvider],
        }).compile();
        service = module.get(ai_service_1.AIService);
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
//# sourceMappingURL=ai.service.spec.js.map