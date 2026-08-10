import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateClientDto, UpdateClientDto } from './dto/client.dto';

@Injectable()
export class ClientsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, dto: CreateClientDto) {
    return this.prisma.client.create({
      data: {
        userId,
        ...dto,
      },
    });
  }

  async findAll(userId: string, search?: string) {
    const where: any = { userId };

    if (search && search.trim() !== '') {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { companyName: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
        { cpfCnpj: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search, mode: 'insensitive' } },
      ];
    }

    return this.prisma.client.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        _count: {
          select: { quotes: true, contracts: true },
        },
      },
    });
  }

  async findOne(userId: string, id: string) {
    const client = await this.prisma.client.findFirst({
      where: { id, userId },
      include: {
        quotes: { orderBy: { createdAt: 'desc' }, take: 5 },
        contracts: { orderBy: { createdAt: 'desc' }, take: 5 },
      },
    });

    if (!client) {
      throw new NotFoundException('Cliente não encontrado');
    }

    return client;
  }

  async update(userId: string, id: string, dto: UpdateClientDto) {
    await this.findOne(userId, id);

    return this.prisma.client.update({
      where: { id },
      data: dto,
    });
  }

  async remove(userId: string, id: string) {
    await this.findOne(userId, id);

    return this.prisma.client.delete({
      where: { id },
    });
  }
}
