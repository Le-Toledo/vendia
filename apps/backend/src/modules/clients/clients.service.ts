import { Prisma } from '@prisma/client';
import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateClientDto, UpdateClientDto } from './dto/client.dto';
import { PaginationDto, paginationMeta } from '../../common/dto/pagination.dto';

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

  async findAll(userId: string, search: string | undefined, { page, pageSize }: PaginationDto) {
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

    const [items, total] = await this.prisma.$transaction([
      this.prisma.client.findMany({
        where,
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { createdAt: 'desc' },
        include: {
          _count: {
            select: { quotes: true, contracts: true },
          },
        },
      }),
      this.prisma.client.count({ where }),
    ]);
    return paginationMeta(items, total, page, pageSize);
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
    const client = await this.findOne(userId, id);
    const linkedMessage =
      'Este cliente não pode ser excluído enquanto possuir orçamentos ou contratos vinculados.';
    if (client.quotes.length || client.contracts.length) {
      throw new ConflictException(linkedMessage);
    }

    try {
      return await this.prisma.client.delete({ where: { id, userId } });
    } catch (error) {
      // A relation may have been created after the ownership/link check.
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2003') {
        throw new ConflictException(linkedMessage);
      }
      throw error;
    }
  }
}
