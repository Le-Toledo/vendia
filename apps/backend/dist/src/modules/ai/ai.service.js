"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var AIService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AIService = void 0;
const common_1 = require("@nestjs/common");
const mock_provider_1 = require("./providers/mock.provider");
const openai_provider_1 = require("./providers/openai.provider");
let AIService = AIService_1 = class AIService {
    constructor(mockProvider, openAiProvider) {
        this.mockProvider = mockProvider;
        this.openAiProvider = openAiProvider;
        this.logger = new common_1.Logger(AIService_1.name);
        const selectedProvider = (process.env.AI_PROVIDER || 'mock').toLowerCase();
        if (selectedProvider === 'openai' && process.env.OPENAI_API_KEY) {
            this.provider = this.openAiProvider;
        }
        else {
            this.provider = this.mockProvider;
        }
        this.logger.log(`🤖 AI Engine inicializada com Provedor: ${this.provider.name}`);
    }
    async processChatMessage(dto) {
        return this.provider.generateText(dto.message, { clientId: dto.clientId });
    }
    async generateMarketingCopy(dto) {
        const prompt = `Crie uma mensagem/descrição de alta conversão para o canal "${dto.targetChannel}" referente ao produto/serviço "${dto.productOrService}". Detalhes adicionais: ${dto.details || 'Nenhum'}`;
        return this.provider.generateText(prompt);
    }
};
exports.AIService = AIService;
exports.AIService = AIService = AIService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [mock_provider_1.MockAIProvider,
        openai_provider_1.OpenAIProvider])
], AIService);
//# sourceMappingURL=ai.service.js.map