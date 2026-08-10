import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../common/prisma/prisma.service';
import { LoginDto, RegisterDto, RefreshTokenDto, GoogleAuthDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { email: dto.email.toLowerCase() },
    });

    if (existingUser) {
      throw new ConflictException('Já existe uma conta vinculada a este e-mail');
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

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email.toLowerCase() },
      include: { profile: true },
    });

    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('E-mail ou senha incorretos');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('E-mail ou senha incorretos');
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

  async googleAuth(dto: GoogleAuthDto) {
    // In production, verify idToken with Google OAuth2 Client
    // For MVP simulation / testing:
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

  async refreshToken(dto: RefreshTokenDto) {
    try {
      const payload = this.jwtService.verify(dto.refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET || 'vendeai_super_secret_refresh_jwt_key_2026',
      });

      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
      });

      if (!user || !user.refreshToken) {
        throw new UnauthorizedException('Refresh token inválido');
      }

      const isMatch = await bcrypt.compare(dto.refreshToken, user.refreshToken);
      if (!isMatch) {
        throw new UnauthorizedException('Refresh token expirado ou substituído');
      }

      const tokens = await this.generateTokens(user.id, user.email);
      await this.updateRefreshToken(user.id, tokens.refreshToken);

      return tokens;
    } catch {
      throw new UnauthorizedException('Refresh token inválido ou expirado');
    }
  }

  async logout(userId: string) {
    await this.prisma.user.update({
      where: { id: userId },
      data: { refreshToken: null },
    });

    return { message: 'Logout realizado com sucesso' };
  }

  private async generateTokens(userId: string, email: string) {
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

  private async updateRefreshToken(userId: string, refreshToken: string) {
    const hash = await bcrypt.hash(refreshToken, 10);
    await this.prisma.user.update({
      where: { id: userId },
      data: { refreshToken: hash },
    });
  }
}
