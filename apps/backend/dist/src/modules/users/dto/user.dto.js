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
exports.UpdateSettingsDto = exports.UpdateProfileDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class UpdateProfileDto {
}
exports.UpdateProfileDto = UpdateProfileDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Carlos Eduardo Silva', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProfileDto.prototype, "fullName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Silva Tech Services Ltda', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProfileDto.prototype, "companyName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: '12.345.678/0001-90', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProfileDto.prototype, "cpfCnpj", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: '(11) 98765-4321', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProfileDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'https://storage.vendeai.com/logo.png', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProfileDto.prototype, "logoUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'https://storage.vendeai.com/avatar.jpg', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProfileDto.prototype, "avatarUrl", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Av. Paulista, 1000', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProfileDto.prototype, "address", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'São Paulo', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProfileDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'SP', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProfileDto.prototype, "state", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: '01310-100', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateProfileDto.prototype, "zipCode", void 0);
class UpdateSettingsDto {
}
exports.UpdateSettingsDto = UpdateSettingsDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'dark', enum: ['light', 'dark', 'system'], required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateSettingsDto.prototype, "themeMode", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'pt-BR', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateSettingsDto.prototype, "language", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'openai', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateSettingsDto.prototype, "aiProvider", void 0);
//# sourceMappingURL=user.dto.js.map