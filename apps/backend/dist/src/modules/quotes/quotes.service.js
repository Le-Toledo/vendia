"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.QuotesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../common/prisma/prisma.service");
const pdf_service_1 = require("./pdf.service");
let QuotesService = class QuotesService {
    constructor(prisma, pdfService) {
        this.prisma = prisma;
        this.pdfService = pdfService;
    }
    async create(userId, dto) {
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
    async findAll(userId, status) {
        const where = { userId };
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
    async findOne(userId, id) {
        const quote = await this.prisma.quote.findFirst({
            where: { id, userId },
            include: {
                client: true,
                items: true,
            },
        });
        if (!quote) {
            throw new common_1.NotFoundException('Orçamento não encontrado');
        }
        return quote;
    }
    async update(userId, id, dto) {
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
    async duplicate(userId, id) {
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
    async remove(userId, id) {
        await this.findOne(userId, id);
        return this.prisma.quote.delete({
            where: { id },
        });
    }
    async generatePdf(userId, id) {
        const quote = await this.findOne(userId, id);
        return this.pdfService.generateQuotePdf(quote);
    }
};
exports.QuotesService = QuotesService;
exports.QuotesService = QuotesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        pdf_service_1.PdfService])
], QuotesService);
//# sourceMappingURL=quotes.service.js.map