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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AIController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const ai_service_1 = require("./ai.service");
const ai_request_dto_1 = require("./dto/ai-request.dto");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
let AIController = class AIController {
    constructor(aiService) {
        this.aiService = aiService;
    }
    chat(dto) {
        return this.aiService.processChatMessage(dto);
    }
    generateCopy(dto) {
        return this.aiService.generateMarketingCopy(dto);
    }
};
exports.AIController = AIController;
__decorate([
    (0, common_1.Post)('chat'),
    (0, swagger_1.ApiOperation)({ summary: 'Conversar com o Assistente de IA VendeAI' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [ai_request_dto_1.ChatAiDto]),
    __metadata("design:returntype", void 0)
], AIController.prototype, "chat", null);
__decorate([
    (0, common_1.Post)('generate-copy'),
    (0, swagger_1.ApiOperation)({ summary: 'Gerar anúncios, posts ou descrições para e-commerce (Mercado Livre, Shopee, Amazon)' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [ai_request_dto_1.GenerateMarketingCopyDto]),
    __metadata("design:returntype", void 0)
], AIController.prototype, "generateCopy", null);
exports.AIController = AIController = __decorate([
    (0, swagger_1.ApiTags)('AI Engine'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('ai'),
    __metadata("design:paramtypes", [ai_service_1.AIService])
], AIController);
//# sourceMappingURL=ai.controller.js.map