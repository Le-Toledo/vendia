import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateFinanceEntryDto, UpdateFinanceEntryDto, CreateCategoryDto } from './dto/finance.dto';
import { FinanceType } from '@prisma/client';

@Injectable()
export class FinanceService {
  constructor(private readonly prisma: PrismaService) {}

  async createEntry(userId: string, dto: CreateFinanceEntryDto) {
    return this.prisma.financeEntry.create({
      data: {
        userId,
        description: dto.description,
        amount: dto.amount,
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

  async findAllEntries(userId: string, type?: FinanceType, month?: number, year?: number) {
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

    return this.prisma.financeEntry.findMany({
      where,
      orderBy: { entryDate: 'desc' },
      include: { category: true },
    });
  }

  async getSummary(userId: string) {
    const entries = await this.prisma.financeEntry.findMany({
      where: { userId },
    });

    let totalIncome = 0;
    let totalExpense = 0;

    entries.forEach((e) => {
      if (e.type === FinanceType.INCOME) {
        totalIncome += e.amount;
      } else {
        totalExpense += e.amount;
      }
    });

    const balance = totalIncome - totalExpense;
    const clientCount = await this.prisma.client.count({ where: { userId } });
    const quoteCount = await this.prisma.quote.count({ where: { userId } });
    const contractCount = await this.prisma.contract.count({ where: { userId } });

    const recentActivities = await this.prisma.financeEntry.findMany({
      where: { userId },
      orderBy: { entryDate: 'desc' },
      take: 5,
      include: { category: true },
    });

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
}
