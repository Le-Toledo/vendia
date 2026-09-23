import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateContractDto, UpdateContractDto } from './dto/contract.dto';
import { ContractStatus, Prisma } from '@prisma/client';
import { PaginationDto, paginationMeta } from '../../common/dto/pagination.dto';

@Injectable()
export class ContractsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, dto: CreateContractDto) {
    await this.assertClientOwnership(userId, dto.clientId);
    return this.prisma.contract.create({
      data: {
        userId,
        clientId: dto.clientId,
        title: dto.title,
        content: dto.content,
        value: new Prisma.Decimal(dto.value),
        status: dto.status || 'DRAFT',
      },
      include: {
        client: true,
      },
    });
  }

  async findAll(userId: string, status: string | undefined, { page, pageSize }: PaginationDto) {
    const where: any = { userId };
    if (status) {
      where.status = status as ContractStatus;
    }

    const [items, total] = await this.prisma.$transaction([
      this.prisma.contract.findMany({
        where,
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { createdAt: 'desc' },
        include: { client: true },
      }),
      this.prisma.contract.count({ where }),
    ]);
    return paginationMeta(items, total, page, pageSize);
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
    await this.assertClientOwnership(userId, dto.clientId);

    return this.prisma.contract.update({
      where: { id },
      data: {
        clientId: dto.clientId,
        title: dto.title,
        content: dto.content,
        value: new Prisma.Decimal(dto.value),
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

  private async assertClientOwnership(userId: string, clientId: string) {
    const client = await this.prisma.client.findFirst({
      where: { id: clientId, userId },
      select: { id: true },
    });
    if (!client) throw new NotFoundException('Cliente não encontrado');
  }
}
