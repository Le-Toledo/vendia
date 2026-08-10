import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { UpdateProfileDto, UpdateSettingsDto } from './dto/user.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

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
}
