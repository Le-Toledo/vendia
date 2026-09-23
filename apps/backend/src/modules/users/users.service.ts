import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { AppleAuthService } from '../auth/apple-auth.service';
import { ConfigService } from '@nestjs/config';
import { PRIVACY_VERSION, aiProviderInfo } from '../app-info/privacy';
import { PrismaService } from '../../common/prisma/prisma.service';
import { UpdateProfileDto, UpdateSettingsDto } from './dto/user.dto';

@Injectable()
export class UsersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly appleAuth: AppleAuthService,
  ) {}

  async setAiConsent(userId: string, approved: boolean, version?: string, provider?: string) {
    const currentProvider = aiProviderInfo(this.config).id;
    if (approved && (version !== PRIVACY_VERSION || provider !== currentProvider)) {
      throw new BadRequestException(
        'A política ou o provedor mudou. Leia e confirme a autorização novamente.',
      );
    }
    const data = {
      aiConsentVersion: approved ? PRIVACY_VERSION : null,
      aiConsentProvider: approved ? currentProvider : null,
      aiConsentAt: approved ? new Date() : null,
    };
    await this.prisma.setting.upsert({
      where: { userId },
      create: { userId, ...data },
      update: data,
    });
    return { approved };
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        role: true,
        profile: true,
        settings: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('Perfil do usuário não encontrado');
    }

    return user;
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    return this.prisma.profile.upsert({
      where: { userId },
      update: dto,
      create: {
        userId,
        fullName: dto.fullName || 'Usuário',
        ...dto,
      },
    });
  }

  async updateSettings(userId: string, dto: UpdateSettingsDto) {
    return this.prisma.setting.upsert({
      where: { userId },
      update: dto,
      create: {
        userId,
        ...dto,
      },
    });
  }

  async exportData(userId: string) {
    const data = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        createdAt: true,
        profile: true,
        settings: true,
        clients: true,
        quotes: { include: { items: true } },
        contracts: true,
        financeEntries: true,
        categories: true,
        notifications: true,
        files: true,
      },
    });
    if (!data) throw new NotFoundException('Perfil do usuário não encontrado');
    return { exportedAt: new Date().toISOString(), data };
  }

  async deleteAccount(userId: string, confirmation: string) {
    if (confirmation !== 'EXCLUIR') throw new BadRequestException('Confirmação inválida');
    const identity = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { appleRefreshToken: true },
    });
    if (identity?.appleRefreshToken) await this.appleAuth.revoke(identity.appleRefreshToken);
    await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.findUnique({ where: { id: userId }, select: { id: true } });
      if (!user) throw new NotFoundException('Perfil do usuário não encontrado');
      // Remove dependents before clients to respect their RESTRICT relations.
      await tx.quote.deleteMany({ where: { userId } });
      await tx.contract.deleteMany({ where: { userId } });
      await tx.auditLog.deleteMany({ where: { userId } });
      await tx.user.delete({ where: { id: userId } });
    });
    return { message: 'Conta e dados associados excluídos' };
  }
}
