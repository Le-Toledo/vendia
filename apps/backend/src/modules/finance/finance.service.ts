import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateFinanceEntryDto, UpdateFinanceEntryDto, CreateCategoryDto } from './dto/finance.dto';
import { FinanceType } from '@prisma/client';
import { Prisma } from '@prisma/client';
import { PaginationDto, paginationMeta } from '../../common/dto/pagination.dto';

@Injectable()
export class FinanceService {
  constructor(private readonly prisma: PrismaService) {}

  async createEntry(userId: string, dto: CreateFinanceEntryDto) {
    await this.assertCategoryOwnership(userId, dto.categoryId);
    return this.prisma.financeEntry.create({
      data: {
        userId,
        description: dto.description,
        amount: new Prisma.Decimal(dto.amount),
        type: dto.type,
        categoryId: dto.categoryId,
        entryDate: dto.entryDate ? new Date(dto.entryDate) : new Date(),
        notes: dto.notes,
      },
      include: {
        category: true,
      },
    });
  }

  async findAllEntries(
    userId: string,
    type: FinanceType | undefined,
    month: number | undefined,
    year: number | undefined,
    { page, pageSize }: PaginationDto,
  ) {
    const where: any = { userId };
    if (type) {
      where.type = type;
    }

    if (month && year) {
      const startDate = new Date(year, month - 1, 1);
      const endDate = new Date(year, month, 0, 23, 59, 59);
      where.entryDate = {
        gte: startDate,
        lte: endDate,
      };
    }

    const [items, total] = await this.prisma.$transaction([
      this.prisma.financeEntry.findMany({
        where,
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { entryDate: 'desc' },
        include: { category: true },
      }),
      this.prisma.financeEntry.count({ where }),
    ]);
    return paginationMeta(items, total, page, pageSize);
  }

  async getSummary(userId: string) {
    const [income, expense, clientCount, quoteCount, contractCount, recentActivities] =
      await this.prisma.$transaction([
        this.prisma.financeEntry.aggregate({
          where: { userId, type: FinanceType.INCOME },
          _sum: { amount: true },
        }),
        this.prisma.financeEntry.aggregate({
          where: { userId, type: FinanceType.EXPENSE },
          _sum: { amount: true },
        }),
        this.prisma.client.count({ where: { userId } }),
        this.prisma.quote.count({ where: { userId } }),
        this.prisma.contract.count({ where: { userId } }),
        this.prisma.financeEntry.findMany({
          where: { userId },
          orderBy: { entryDate: 'desc' },
          take: 5,
          include: { category: true },
        }),
      ]);
    const totalIncome = income._sum.amount ?? new Prisma.Decimal(0);
    const totalExpense = expense._sum.amount ?? new Prisma.Decimal(0);
    const balance = totalIncome.sub(totalExpense);

    return {
      financial: {
        totalIncome,
        totalExpense,
        balance,
      },
      metrics: {
        clientCount,
        quoteCount,
        contractCount,
      },
      recentActivities,
    };
  }

  async createCategory(userId: string, dto: CreateCategoryDto) {
    return this.prisma.category.create({
      data: {
        userId,
        name: dto.name,
        type: dto.type,
        colorHex: dto.colorHex || '#4F46E5',
      },
    });
  }

  async getCategories(userId: string, type?: FinanceType) {
    const where: any = { userId };
    if (type) {
      where.type = type;
    }

    return this.prisma.category.findMany({
      where,
      orderBy: { name: 'asc' },
    });
  }

  async deleteEntry(userId: string, id: string) {
    const entry = await this.prisma.financeEntry.findFirst({ where: { id, userId } });
    if (!entry) throw new NotFoundException('Lançamento não encontrado');

    return this.prisma.financeEntry.delete({ where: { id } });
  }

  async updateEntry(userId: string, id: string, dto: UpdateFinanceEntryDto) {
    const entry = await this.prisma.financeEntry.findFirst({
      where: { id, userId },
      select: { id: true },
    });
    if (!entry) throw new NotFoundException('Lançamento não encontrado');
    await this.assertCategoryOwnership(userId, dto.categoryId);
    return this.prisma.financeEntry.update({
      where: { id },
      data: {
        description: dto.description,
        amount: new Prisma.Decimal(dto.amount),
        type: dto.type,
        categoryId: dto.categoryId,
        entryDate: dto.entryDate ? new Date(dto.entryDate) : undefined,
        notes: dto.notes,
      },
      include: { category: true },
    });
  }

  private async assertCategoryOwnership(userId: string, categoryId?: string) {
    if (!categoryId) return;
    const category = await this.prisma.category.findFirst({
      where: { id: categoryId, userId },
      select: { id: true },
    });
    if (!category) throw new NotFoundException('Categoria não encontrada');
  }
}
