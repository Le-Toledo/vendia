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
exports.GoogleAuthDto = exports.RefreshTokenDto = exports.LoginDto = exports.RegisterDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class RegisterDto {
}
exports.RegisterDto = RegisterDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'João Silva', description: 'Nome completo do usuário' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'O nome é obrigatório' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "fullName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'joao@empresa.com.br', description: 'E-mail para login' }),
    (0, class_validator_1.IsEmail)({}, { message: 'Forneça um e-mail válido' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'SenhaForte123!', description: 'Senha de acesso' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(6, { message: 'A senha deve conter no mínimo 6 caracteres' }),
    __metadata("design:type", String)
], RegisterDto.prototype, "password", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Silva Soluções MEI', required: false }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], RegisterDto.prototype, "companyName", void 0);
class LoginDto {
}
exports.LoginDto = LoginDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'joao@empresa.com.br' }),
    (0, class_validator_1.IsEmail)({}, { message: 'Forneça um e-mail válido' }),
    __metadata("design:type", String)
], LoginDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'SenhaForte123!' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'A senha é obrigatória' }),
    __metadata("design:type", String)
], LoginDto.prototype, "password", void 0);
class RefreshTokenDto {
}
exports.RefreshTokenDto = RefreshTokenDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'Refresh Token de renovação de sessão' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'O refresh token é obrigatório' }),
    __metadata("design:type", String)
], RefreshTokenDto.prototype, "refreshToken", void 0);
class GoogleAuthDto {
}
exports.GoogleAuthDto = GoogleAuthDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: 'ID Token retornado pelo Google OAuth' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: 'O idToken do Google é obrigatório' }),
    __metadata("design:type", String)
], GoogleAuthDto.prototype, "idToken", void 0);
//# sourceMappingURL=auth.dto.js.map