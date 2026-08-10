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
exports.UpdateClientDto = exports.CreateClientDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class CreateClientDto {
}
exports.CreateClientDto = CreateClientDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'João Pereira', description: 'Nome ou razão social' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'O nome do cliente é obrigatório' }),
    __metadata("design:type", String)
], CreateClientDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Pereira & Cia Ltda', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateClientDto.prototype, "companyName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'joao@pereira.com.br', required: false }),
    (0, class_validator_1.IsEmail)({}, { message: 'Forneça um e-mail válido' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateClientDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: '(11) 98888-7777', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateClientDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: '123.456.789-00', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateClientDto.prototype, "cpfCnpj", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Rua Augusta, 1500 - SP', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateClientDto.prototype, "address", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Cliente prefere atendimento por WhatsApp', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateClientDto.prototype, "notes", void 0);
class UpdateClientDto extends CreateClientDto {
}
exports.UpdateClientDto = UpdateClientDto;
//# sourceMappingURL=client.dto.js.map