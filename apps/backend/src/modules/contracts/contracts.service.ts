import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateContractDto, UpdateContractDto } from './dto/contract.dto';

@Injectable()
export class ContractsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, dto: CreateContractDto) {
    return this.prisma.contract.create({
      data: {
        userId,
        clientId: dto.clientId,
        title: dto.title,
        content: dto.content,
        value: dto.value,
        status: dto.status || 'DRAFT',
      },
      include: {
        client: true,
      },
    });
  }

  async findAll(userId: string, status?: string) {
    const where: any = { userId };
    if (status) {
      where.status = status;
    }

    return this.prisma.contract.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        client: true,
      },
    });
  }

  async findOne(userId: string, id: string) {
    const contract = await this.prisma.contract.findFirst({
      where: { id, userId },
      include: {
        client: true,
      },
    });

    if (!contract) {
      throw new NotFoundException('Contrato não encontrado');
    }

    return contract;
  }

  async update(userId: string, id: string, dto: UpdateContractDto) {
    await this.findOne(userId, id);

    return this.prisma.contract.update({
      where: { id },
      data: {
        clientId: dto.clientId,
        title: dto.title,
        content: dto.content,
        value: dto.value,
        status: dto.status,
      },
      include: {
        client: true,
      },
    });
  }

  async remove(userId: string, id: string) {
    await this.findOne(userId, id);

    return this.prisma.contract.delete({
      where: { id },
    });
  }
}
