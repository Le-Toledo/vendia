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
exports.UpdateQuoteDto = exports.CreateQuoteDto = exports.QuoteItemDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_transformer_1 = require("class-transformer");
const class_validator_1 = require("class-validator");
const client_1 = require("@prisma/client");
class QuoteItemDto {
}
exports.QuoteItemDto = QuoteItemDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Desenvolvimento Web' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], QuoteItemDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 1 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], QuoteItemDto.prototype, "quantity", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 1500.0 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], QuoteItemDto.prototype, "unitPrice", void 0);
class CreateQuoteDto {
}
exports.CreateQuoteDto = CreateQuoteDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'client-uuid-123' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'O cliente é obrigatório' }),
    __metadata("design:type", String)
], CreateQuoteDto.prototype, "clientId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 100.0, required: false }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreateQuoteDto.prototype, "discount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Validade de 15 dias', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateQuoteDto.prototype, "notes", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ enum: client_1.QuoteStatus, default: client_1.QuoteStatus.DRAFT, required: false }),
    (0, class_validator_1.IsEnum)(client_1.QuoteStatus),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateQuoteDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: [QuoteItemDto] }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.ValidateNested)({ each: true }),
    (0, class_transformer_1.Type)(() => QuoteItemDto),
    __metadata("design:type", Array)
], CreateQuoteDto.prototype, "items", void 0);
class UpdateQuoteDto extends CreateQuoteDto {
}
exports.UpdateQuoteDto = UpdateQuoteDto;
//# sourceMappingURL=quote.dto.js.map