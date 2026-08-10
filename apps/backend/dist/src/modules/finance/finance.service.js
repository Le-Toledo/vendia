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
exports.FinanceService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../common/prisma/prisma.service");
const client_1 = require("@prisma/client");
let FinanceService = class FinanceService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async createEntry(userId, dto) {
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
    async findAllEntries(userId, type, month, year) {
        const where = { userId };
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
    async getSummary(userId) {
        const entries = await this.prisma.financeEntry.findMany({
            where: { userId },
        });
        let totalIncome = 0;
        let totalExpense = 0;
        entries.forEach((e) => {
            if (e.type === client_1.FinanceType.INCOME) {
                totalIncome += e.amount;
            }
            else {
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
    async createCategory(userId, dto) {
        return this.prisma.category.create({
            data: {
                userId,
                name: dto.name,
                type: dto.type,
                colorHex: dto.colorHex || '#4F46E5',
            },
        });
    }
    async getCategories(userId, type) {
        const where = { userId };
        if (type) {
            where.type = type;
        }
        return this.prisma.category.findMany({
            where,
            orderBy: { name: 'asc' },
        });
    }
    async deleteEntry(userId, id) {
        const entry = await this.prisma.financeEntry.findFirst({ where: { id, userId } });
        if (!entry)
            throw new common_1.NotFoundException('Lançamento não encontrado');
        return this.prisma.financeEntry.delete({ where: { id } });
    }
};
exports.FinanceService = FinanceService;
exports.FinanceService = FinanceService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], FinanceService);
//# sourceMappingURL=finance.service.js.map