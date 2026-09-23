import { AppleAuthService } from './apple-auth.service';
import { AppleAuthDto } from './dto/auth.dto';
import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService, JwtSignOptions } from '@nestjs/jwt';
import { createHash, randomUUID } from 'crypto';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../common/prisma/prisma.service';
import { LoginDto, RegisterDto, RefreshTokenDto, GoogleAuthDto } from './dto/auth.dto';
import { ConfigService } from '@nestjs/config';
import { GoogleTokenVerifier } from './google-token-verifier.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
    private readonly googleTokenVerifier: GoogleTokenVerifier,
    private readonly appleAuthService: AppleAuthService,
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

    const tokens = await this.generateTokens(user.id, user.email, user.sessionVersion);
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

    if (!user || !user.passwordHash || !user.isActive) {
      throw new UnauthorizedException('E-mail ou senha incorretos');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('E-mail ou senha incorretos');
    }

    const tokens = await this.generateTokens(user.id, user.email, user.sessionVersion);
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
    const identity = await this.googleTokenVerifier.verify(dto.idToken);
    const byGoogleId = await this.prisma.user.findUnique({ where: { googleId: identity.subject } });
    const byEmail = await this.prisma.user.findUnique({ where: { email: identity.email } });
    if (byGoogleId && byEmail && byGoogleId.id !== byEmail.id) {
      throw new ConflictException('Não foi possível vincular esta conta Google');
    }

    const existing = byGoogleId || byEmail;
    if (existing && !existing.isActive) throw new UnauthorizedException('Conta indisponível');
    const user = existing
      ? await this.prisma.user.update({
          where: { id: existing.id },
          data: { googleId: identity.subject },
          include: { profile: true },
        })
      : await this.prisma.user.create({
          data: {
            email: identity.email,
            googleId: identity.subject,
            profile: { create: { fullName: identity.name } },
            settings: { create: {} },
          },
          include: { profile: true },
        });

    const tokens = await this.generateTokens(user.id, user.email, user.sessionVersion);
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

  async appleAuth(dto: AppleAuthDto) {
    const identity = await this.appleAuthService.authenticate(dto.authorizationCode, dto.nonce);
    const byApple = await this.prisma.user.findUnique({ where: { appleId: identity.subject } });
    const byEmail = await this.prisma.user.findUnique({ where: { email: identity.email } });
    if (
      (byApple && byEmail && byApple.id !== byEmail.id) ||
      (byEmail?.appleId && byEmail.appleId !== identity.subject)
    )
      throw new ConflictException('Não foi possível vincular esta conta Apple.');
    const existing = byApple || byEmail;
    if (existing && !existing.isActive) throw new UnauthorizedException('Conta indisponível');
    const data = { appleId: identity.subject, appleRefreshToken: identity.encryptedRefreshToken };
    const user = existing
      ? await this.prisma.user.update({
          where: { id: existing.id },
          data,
          include: { profile: true },
        })
      : await this.prisma.user.create({
          data: {
            ...data,
            email: identity.email,
            profile: { create: { fullName: 'Usuário VendAI' } },
            settings: { create: {} },
          },
          include: { profile: true },
        });
    const tokens = await this.generateTokens(user.id, user.email, user.sessionVersion);
    await this.updateRefreshToken(user.id, tokens.refreshToken);
    return { user: { id: user.id, email: user.email, profile: user.profile }, tokens };
  }

  async refreshToken(dto: RefreshTokenDto) {
    try {
      const payload = this.jwtService.verify(dto.refreshToken, {
        secret: this.requiredConfig('JWT_REFRESH_SECRET'),
      });

      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
      });

      if (
        !user ||
        !user.isActive ||
        !user.refreshToken ||
        (payload.sv ?? 0) !== user.sessionVersion
      ) {
        throw new UnauthorizedException('Refresh token inválido');
      }

      if (user.appleRefreshToken)
        await this.appleAuthService.validateStoredAuthorization(user.appleRefreshToken);
      const storedHash = user.refreshToken;
      const isVersioned = storedHash.startsWith('sha256:');
      const candidate = isVersioned
        ? createHash('sha256').update(dto.refreshToken).digest('hex')
        : dto.refreshToken;
      const isMatch = await bcrypt.compare(
        candidate,
        isVersioned ? storedHash.slice(7) : storedHash,
      );
      if (!isMatch) {
        throw new UnauthorizedException('Refresh token expirado ou substituído');
      }

      const tokens = await this.generateTokens(user.id, user.email, user.sessionVersion);
      const hash = await this.hashRefreshToken(tokens.refreshToken);
      const rotated = await this.prisma.user.updateMany({
        where: { id: user.id, refreshToken: storedHash, sessionVersion: user.sessionVersion },
        data: { refreshToken: hash },
      });
      if (!rotated.count) throw new UnauthorizedException('Refresh token substituído');
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

  private async generateTokens(userId: string, email: string, sessionVersion: number) {
    const payload = { sub: userId, email, sv: sessionVersion };

    const accessToken = this.jwtService.sign(payload, {
      secret: this.requiredConfig('JWT_SECRET'),
      expiresIn: this.config.get<string>('JWT_EXPIRES_IN', '15m') as JwtSignOptions['expiresIn'],
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: this.requiredConfig('JWT_REFRESH_SECRET'),
      jwtid: randomUUID(),
      expiresIn: this.config.get<string>(
        'JWT_REFRESH_EXPIRES_IN',
        '7d',
      ) as JwtSignOptions['expiresIn'],
    });

    return { accessToken, refreshToken };
  }

  private async updateRefreshToken(userId: string, refreshToken: string) {
    const hash = await this.hashRefreshToken(refreshToken);
    await this.prisma.user.update({
      where: { id: userId },
      data: { refreshToken: hash },
    });
  }

  private async hashRefreshToken(token: string) {
    const digest = createHash('sha256').update(token).digest('hex');
    return `sha256:${await bcrypt.hash(digest, 10)}`;
  }

  private requiredConfig(key: string): string {
    const value = this.config.get<string>(key);
    if (!value) throw new Error(`Missing required configuration: ${key}`);
    return value;
  }
}
