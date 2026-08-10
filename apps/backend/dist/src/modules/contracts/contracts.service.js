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
exports.ContractsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../common/prisma/prisma.service");
let ContractsService = class ContractsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(userId, dto) {
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
    async findAll(userId, status) {
        const where = { userId };
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
    async findOne(userId, id) {
        const contract = await this.prisma.contract.findFirst({
            where: { id, userId },
            include: {
                client: true,
            },
        });
        if (!contract) {
            throw new common_1.NotFoundException('Contrato não encontrado');
        }
        return contract;
    }
    async update(userId, id, dto) {
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
    async remove(userId, id) {
        await this.findOne(userId, id);
        return this.prisma.contract.delete({
            where: { id },
        });
    }
};
exports.ContractsService = ContractsService;
exports.ContractsService = ContractsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ContractsService);
//# sourceMappingURL=contracts.service.js.map