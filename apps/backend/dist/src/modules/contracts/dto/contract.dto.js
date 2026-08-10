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
exports.UpdateContractDto = exports.GenerateContractAiDto = exports.CreateContractDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const client_1 = require("@prisma/client");
class CreateContractDto {
}
exports.CreateContractDto = CreateContractDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'client-uuid-123' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'O cliente é obrigatório' }),
    __metadata("design:type", String)
], CreateContractDto.prototype, "clientId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Contrato de Prestação de Serviços de TI' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'O título do contrato é obrigatório' }),
    __metadata("design:type", String)
], CreateContractDto.prototype, "title", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Cláusula 1: O prestador compromete-se a...' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'O conteúdo do contrato é obrigatório' }),
    __metadata("design:type", String)
], CreateContractDto.prototype, "content", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 5000.0 }),
    (0, class_validator_1.IsNumber)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], CreateContractDto.prototype, "value", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ enum: client_1.ContractStatus, default: client_1.ContractStatus.DRAFT, required: false }),
    (0, class_validator_1.IsEnum)(client_1.ContractStatus),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateContractDto.prototype, "status", void 0);
class GenerateContractAiDto {
}
exports.GenerateContractAiDto = GenerateContractAiDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'client-uuid-123' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], GenerateContractAiDto.prototype, "clientId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Prestação de serviço de desenvolvimento de software mobile no valor de R$ 5.000 com prazo de 30 dias.' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], GenerateContractAiDto.prototype, "promptInstructions", void 0);
class UpdateContractDto extends CreateContractDto {
}
exports.UpdateContractDto = UpdateContractDto;
//# sourceMappingURL=contract.dto.js.map