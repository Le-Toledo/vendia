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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FinanceController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const finance_service_1 = require("./finance.service");
const finance_dto_1 = require("./dto/finance.dto");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
const current_user_decorator_1 = require("../../common/decorators/current-user.decorator");
const client_1 = require("@prisma/client");
let FinanceController = class FinanceController {
    constructor(financeService) {
        this.financeService = financeService;
    }
    createEntry(user, dto) {
        return this.financeService.createEntry(user.id, dto);
    }
    findAllEntries(user, type, month, year) {
        return this.financeService.findAllEntries(user.id, type, month ? parseInt(month, 10) : undefined, year ? parseInt(year, 10) : undefined);
    }
    getSummary(user) {
        return this.financeService.getSummary(user.id);
    }
    createCategory(user, dto) {
        return this.financeService.createCategory(user.id, dto);
    }
    getCategories(user, type) {
        return this.financeService.getCategories(user.id, type);
    }
    deleteEntry(user, id) {
        return this.financeService.deleteEntry(user.id, id);
    }
};
exports.FinanceController = FinanceController;
__decorate([
    (0, common_1.Post)('entries'),
    (0, swagger_1.ApiOperation)({ summary: 'Registrar nova entrada ou saída financeira' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, finance_dto_1.CreateFinanceEntryDto]),
    __metadata("design:returntype", void 0)
], FinanceController.prototype, "createEntry", null);
__decorate([
    (0, common_1.Get)('entries'),
    (0, swagger_1.ApiOperation)({ summary: 'Listar extrato de lançamentos financeiros' }),
    (0, swagger_1.ApiQuery)({ name: 'type', required: false, enum: client_1.FinanceType }),
    (0, swagger_1.ApiQuery)({ name: 'month', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'year', required: false, type: Number }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('type')),
    __param(2, (0, common_1.Query)('month')),
    __param(3, (0, common_1.Query)('year')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String, String]),
    __metadata("design:returntype", void 0)
], FinanceController.prototype, "findAllEntries", null);
__decorate([
    (0, common_1.Get)('summary'),
    (0, swagger_1.ApiOperation)({ summary: 'Obter resumo mensal, saldo total e métricas do dashboard' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], FinanceController.prototype, "getSummary", null);
__decorate([
    (0, common_1.Post)('categories'),
    (0, swagger_1.ApiOperation)({ summary: 'Criar nova categoria financeira' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, finance_dto_1.CreateCategoryDto]),
    __metadata("design:returntype", void 0)
], FinanceController.prototype, "createCategory", null);
__decorate([
    (0, common_1.Get)('categories'),
    (0, swagger_1.ApiOperation)({ summary: 'Listar categorias de receitas ou despesas' }),
    (0, swagger_1.ApiQuery)({ name: 'type', required: false, enum: client_1.FinanceType }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('type')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], FinanceController.prototype, "getCategories", null);
__decorate([
    (0, common_1.Delete)('entries/:id'),
    (0, swagger_1.ApiOperation)({ summary: 'Excluir lançamento financeiro' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], FinanceController.prototype, "deleteEntry", null);
exports.FinanceController = FinanceController = __decorate([
    (0, swagger_1.ApiTags)('Finance'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('finance'),
    __metadata("design:paramtypes", [finance_service_1.FinanceService])
], FinanceController);
//# sourceMappingURL=finance.controller.js.map