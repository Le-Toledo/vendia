import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateQuoteDto, UpdateQuoteDto } from './dto/quote.dto';
import { PdfService } from './pdf.service';
import { Prisma, QuoteStatus } from '@prisma/client';
import { randomUUID } from 'crypto';
import { PaginationDto, paginationMeta } from '../../common/dto/pagination.dto';

@Injectable()
export class QuotesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly pdfService: PdfService,
  ) {}

  async create(userId: string, dto: CreateQuoteDto) {
    await this.assertClientOwnership(userId, dto.clientId);
    const codeNumber = `ORC-${new Date().getFullYear()}-${randomUUID().slice(0, 8).toUpperCase()}`;

    let subtotal = new Prisma.Decimal(0);
    const itemsData = dto.items.map((item) => {
      const unitPrice = new Prisma.Decimal(item.unitPrice);
      const itemTotal = unitPrice.mul(item.quantity);
      subtotal = subtotal.add(itemTotal);
      return {
        description: item.description,
        quantity: item.quantity,
        unitPrice,
        totalPrice: itemTotal,
      };
    });

    const discount = new Prisma.Decimal(dto.discount || 0);
    const total = Prisma.Decimal.max(0, subtotal.sub(discount));

    return this.prisma.quote.create({
      data: {
        userId,
        clientId: dto.clientId,
        codeNumber,
        status: dto.status || 'DRAFT',
        subtotal,
        discount,
        total,
        notes: dto.notes,
        items: {
          create: itemsData,
        },
      },
      include: {
        client: true,
        items: true,
      },
    });
  }

  async findAll(userId: string, status: string | undefined, { page, pageSize }: PaginationDto) {
    const where: any = { userId };
    if (status) {
      where.status = status as QuoteStatus;
    }

    const [items, total] = await this.prisma.$transaction([
      this.prisma.quote.findMany({
        where,
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { createdAt: 'desc' },
        include: { client: true, items: true },
      }),
      this.prisma.quote.count({ where }),
    ]);
    return paginationMeta(items, total, page, pageSize);
  }

  async findOne(userId: string, id: string) {
    const quote = await this.prisma.quote.findFirst({
      where: { id, userId },
      include: {
        client: true,
        items: true,
      },
    });

    if (!quote) {
      throw new NotFoundException('Orçamento não encontrado');
    }

    return quote;
  }

  async update(userId: string, id: string, dto: UpdateQuoteDto) {
    await this.findOne(userId, id);
    await this.assertClientOwnership(userId, dto.clientId);

    let subtotal = new Prisma.Decimal(0);
    const itemsData = dto.items.map((item) => {
      const unitPrice = new Prisma.Decimal(item.unitPrice);
      const itemTotal = unitPrice.mul(item.quantity);
      subtotal = subtotal.add(itemTotal);
      return {
        description: item.description,
        quantity: item.quantity,
        unitPrice,
        totalPrice: itemTotal,
      };
    });

    const discount = new Prisma.Decimal(dto.discount || 0);
    const total = Prisma.Decimal.max(0, subtotal.sub(discount));

    return this.prisma.$transaction(async (tx) => {
      await tx.quoteItem.deleteMany({ where: { quoteId: id } });
      return tx.quote.update({
        where: { id },
        data: {
          clientId: dto.clientId,
          status: dto.status,
          subtotal,
          discount,
          total,
          notes: dto.notes,
          items: { create: itemsData },
        },
        include: { client: true, items: true },
      });
    });
  }

  async duplicate(userId: string, id: string) {
    const original = await this.findOne(userId, id);

    return this.create(userId, {
      clientId: original.clientId,
      discount: original.discount.toNumber(),
      notes: `Cópia de ${original.codeNumber}. ${original.notes || ''}`,
      status: 'DRAFT',
      items: original.items.map((i) => ({
        description: i.description,
        quantity: i.quantity,
        unitPrice: i.unitPrice.toNumber(),
      })),
    });
  }

  async remove(userId: string, id: string) {
    await this.findOne(userId, id);

    return this.prisma.quote.delete({
      where: { id },
    });
  }

  async generatePdf(userId: string, id: string): Promise<Buffer> {
    const quote = await this.findOne(userId, id);
    return this.pdfService.generateQuotePdf(quote);
  }

  private async assertClientOwnership(userId: string, clientId: string) {
    const client = await this.prisma.client.findFirst({
      where: { id: clientId, userId },
      select: { id: true },
    });
    if (!client) throw new NotFoundException('Cliente não encontrado');
  }
}
