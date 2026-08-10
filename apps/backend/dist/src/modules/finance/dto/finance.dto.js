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
exports.UpdateFinanceEntryDto = exports.CreateCategoryDto = exports.CreateFinanceEntryDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const client_1 = require("@prisma/client");
class CreateFinanceEntryDto {
}
exports.CreateFinanceEntryDto = CreateFinanceEntryDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Pagamento Projeto App Mobile' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'A descrição da entrada/saída é obrigatória' }),
    __metadata("design:type", String)
], CreateFinanceEntryDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 2500.0 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0.01, { message: 'O valor deve ser maior que zero' }),
    __metadata("design:type", Number)
], CreateFinanceEntryDto.prototype, "amount", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ enum: client_1.FinanceType, example: client_1.FinanceType.INCOME }),
    (0, class_validator_1.IsEnum)(client_1.FinanceType),
    __metadata("design:type", String)
], CreateFinanceEntryDto.prototype, "type", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'category-uuid-123', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateFinanceEntryDto.prototype, "categoryId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: '2026-08-01T00:00:00.000Z', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateFinanceEntryDto.prototype, "entryDate", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Pagamento via PIX em 2x', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateFinanceEntryDto.prototype, "notes", void 0);
class CreateCategoryDto {
}
exports.CreateCategoryDto = CreateCategoryDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Consultoria Especializada' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'O nome da categoria é obrigatório' }),
    __metadata("design:type", String)
], CreateCategoryDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ enum: client_1.FinanceType, example: client_1.FinanceType.INCOME }),
    (0, class_validator_1.IsEnum)(client_1.FinanceType),
    __metadata("design:type", String)
], CreateCategoryDto.prototype, "type", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: '#10B981', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateCategoryDto.prototype, "colorHex", void 0);
class UpdateFinanceEntryDto extends CreateFinanceEntryDto {
}
exports.UpdateFinanceEntryDto = UpdateFinanceEntryDto;
//# sourceMappingURL=finance.dto.js.map