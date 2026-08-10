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
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = require("bcrypt");
const prisma_service_1 = require("../../common/prisma/prisma.service");
let AuthService = class AuthService {
    constructor(prisma, jwtService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
    }
    async register(dto) {
        const existingUser = await this.prisma.user.findUnique({
            where: { email: dto.email.toLowerCase() },
        });
        if (existingUser) {
            throw new common_1.ConflictException('Já existe uma conta vinculada a este e-mail');
        }
        const passwordHash = await bcrypt.hash(dto.password, 10);
        const user = await this.prisma.user.create({
            data: {
                email: dto.email.toLowerCase(),
                passwordHash,
                profile: {
                    create: {
                        fullName: dto.fullName,
                        companyName: dto.companyName,
                    },
                },
                settings: {
                    create: {
                        themeMode: 'system',
                        language: 'pt-BR',
                    },
                },
            },
            include: { profile: true },
        });
        const tokens = await this.generateTokens(user.id, user.email);
        await this.updateRefreshToken(user.id, tokens.refreshToken);
        return {
            user: {
                id: user.id,
                email: user.email,
                profile: user.profile,
            },
            tokens,
        };
    }
    async login(dto) {
        const user = await this.prisma.user.findUnique({
            where: { email: dto.email.toLowerCase() },
            include: { profile: true },
        });
        if (!user || !user.passwordHash) {
            throw new common_1.UnauthorizedException('E-mail ou senha incorretos');
        }
        const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
        if (!isPasswordValid) {
            throw new common_1.UnauthorizedException('E-mail ou senha incorretos');
        }
        const tokens = await this.generateTokens(user.id, user.email);
        await this.updateRefreshToken(user.id, tokens.refreshToken);
        return {
            user: {
                id: user.id,
                email: user.email,
                profile: user.profile,
            },
            tokens,
        };
    }
    async googleAuth(dto) {
        const mockEmail = 'google_user@vendeai.com.br';
        const mockName = 'Usuário Google';
        let user = await this.prisma.user.findUnique({
            where: { email: mockEmail },
            include: { profile: true },
        });
        if (!user) {
            user = await this.prisma.user.create({
                data: {
                    email: mockEmail,
                    googleId: 'google_mock_id_12345',
                    profile: {
                        create: {
                            fullName: mockName,
                        },
                    },
                    settings: {
                        create: {},
                    },
                },
                include: { profile: true },
            });
        }
        const tokens = await this.generateTokens(user.id, user.email);
        await this.updateRefreshToken(user.id, tokens.refreshToken);
        return {
            user: {
                id: user.id,
                email: user.email,
                profile: user.profile,
            },
            tokens,
        };
    }
    async refreshToken(dto) {
        try {
            const payload = this.jwtService.verify(dto.refreshToken, {
                secret: process.env.JWT_REFRESH_SECRET || 'vendeai_super_secret_refresh_jwt_key_2026',
            });
            const user = await this.prisma.user.findUnique({
                where: { id: payload.sub },
            });
            if (!user || !user.refreshToken) {
                throw new common_1.UnauthorizedException('Refresh token inválido');
            }
            const isMatch = await bcrypt.compare(dto.refreshToken, user.refreshToken);
            if (!isMatch) {
                throw new common_1.UnauthorizedException('Refresh token expirado ou substituído');
            }
            const tokens = await this.generateTokens(user.id, user.email);
            await this.updateRefreshToken(user.id, tokens.refreshToken);
            return tokens;
        }
        catch {
            throw new common_1.UnauthorizedException('Refresh token inválido ou expirado');
        }
    }
    async logout(userId) {
        await this.prisma.user.update({
            where: { id: userId },
            data: { refreshToken: null },
        });
        return { message: 'Logout realizado com sucesso' };
    }
    async generateTokens(userId, email) {
        const payload = { sub: userId, email };
        const accessToken = this.jwtService.sign(payload, {
            secret: process.env.JWT_SECRET || 'vendeai_super_secret_jwt_key_2026',
            expiresIn: process.env.JWT_EXPIRES_IN || '15m',
        });
        const refreshToken = this.jwtService.sign(payload, {
            secret: process.env.JWT_REFRESH_SECRET || 'vendeai_super_secret_refresh_jwt_key_2026',
            expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
        });
        return { accessToken, refreshToken };
    }
    async updateRefreshToken(userId, refreshToken) {
        const hash = await bcrypt.hash(refreshToken, 10);
        await this.prisma.user.update({
            where: { id: userId },
            data: { refreshToken: hash },
        });
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map