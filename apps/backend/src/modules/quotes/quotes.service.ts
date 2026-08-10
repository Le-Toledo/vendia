import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateQuoteDto, UpdateQuoteDto } from './dto/quote.dto';
import { PdfService } from './pdf.service';

@Injectable()
export class QuotesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly pdfService: PdfService,
  ) {}

  async create(userId: string, dto: CreateQuoteDto) {
    const codeNumber = `ORC-${new Date().getFullYear()}-${Math.floor(1000 + Math.random() * 9000)}`;

    let subtotal = 0;
    const itemsData = dto.items.map((item) => {
      const itemTotal = item.quantity * item.unitPrice;
      subtotal += itemTotal;
      return {
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: itemTotal,
      };
    });

    const discount = dto.discount || 0;
    const total = Math.max(0, subtotal - discount);

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

  async findAll(userId: string, status?: string) {
    const where: any = { userId };
    if (status) {
      where.status = status;
    }

    return this.prisma.quote.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        client: true,
        items: true,
      },
    });
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

    let subtotal = 0;
    const itemsData = dto.items.map((item) => {
      const itemTotal = item.quantity * item.unitPrice;
      subtotal += itemTotal;
      return {
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: itemTotal,
      };
    });

    const discount = dto.discount || 0;
    const total = Math.max(0, subtotal - discount);

    // Delete existing items & recreate
    await this.prisma.quoteItem.deleteMany({ where: { quoteId: id } });

    return this.prisma.quote.update({
      where: { id },
      data: {
        clientId: dto.clientId,
        status: dto.status,
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

  async duplicate(userId: string, id: string) {
    const original = await this.findOne(userId, id);

    return this.create(userId, {
      clientId: original.clientId,
      discount: original.discount,
      notes: `Cópia de ${original.codeNumber}. ${original.notes || ''}`,
      status: 'DRAFT',
      items: original.items.map((i) => ({
        description: i.description,
        quantity: i.quantity,
        unitPrice: i.unitPrice,
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
}
