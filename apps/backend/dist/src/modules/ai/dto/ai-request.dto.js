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
Object.defineProperty(exports, "__esModule", { value: true });
exports.GenerateMarketingCopyDto = exports.ChatAiDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class ChatAiDto {
}
exports.ChatAiDto = ChatAiDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Crie um orçamento para desenvolvimento de site no valor de R$ 2500' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'A mensagem do prompt é obrigatória' }),
    __metadata("design:type", String)
], ChatAiDto.prototype, "message", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'client-uuid-123', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], ChatAiDto.prototype, "clientId", void 0);
class GenerateMarketingCopyDto {
}
exports.GenerateMarketingCopyDto = GenerateMarketingCopyDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Post Instagram', description: 'Canal: Instagram, Facebook, WhatsApp, Mercado Livre, Shopee, Amazon, Ads' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], GenerateMarketingCopyDto.prototype, "targetChannel", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Manutenção de Computadores e Notebooks' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], GenerateMarketingCopyDto.prototype, "productOrService", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Desconto de 20% para primeiros clientes', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], GenerateMarketingCopyDto.prototype, "details", void 0);
//# sourceMappingURL=ai-request.dto.js.map