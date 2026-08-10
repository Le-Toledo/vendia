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
exports.QuotesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const quotes_service_1 = require("./quotes.service");
const quote_dto_1 = require("./dto/quote.dto");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
const current_user_decorator_1 = require("../../common/decorators/current-user.decorator");
let QuotesController = class QuotesController {
    constructor(quotesService) {
        this.quotesService = quotesService;
    }
    create(user, dto) {
        return this.quotesService.create(user.id, dto);
    }
    findAll(user, status) {
        return this.quotesService.findAll(user.id, status);
    }
    findOne(user, id) {
        return this.quotesService.findOne(user.id, id);
    }
    duplicate(user, id) {
        return this.quotesService.duplicate(user.id, id);
    }
    async downloadPdf(user, id, res) {
        const pdfBuffer = await this.quotesService.generatePdf(user.id, id);
        res.set({
            'Content-Type': 'application/pdf',
            'Content-Disposition': `attachment; filename="Orcamento_${id}.pdf"`,
            'Content-Length': pdfBuffer.length,
        });
        res.end(pdfBuffer);
    }
    update(user, id, dto) {
        return this.quotesService.update(user.id, id, dto);
    }
    remove(user, id) {
        return this.quotesService.remove(user.id, id);
    }
};
exports.QuotesController = QuotesController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Criar novo orçamento' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, quote_dto_1.CreateQuoteDto]),
    __metadata("design:returntype", void 0)
], QuotesController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Listar orçamentos do usuário com filtro por status' }),
    (0, swagger_1.ApiQuery)({ name: 'status', required: false, enum: ['DRAFT', 'SENT', 'APPROVED', 'REJECTED'] }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], QuotesController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Obter detalhes de um orçamento' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], QuotesController.prototype, "findOne", null);
__decorate([
    (0, common_1.Post)(':id/duplicate'),
    (0, swagger_1.ApiOperation)({ summary: 'Duplicar um orçamento existente como rascunho' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], QuotesController.prototype, "duplicate", null);
__decorate([
    (0, common_1.Get)(':id/pdf'),
    (0, swagger_1.ApiOperation)({ summary: 'Gerar e baixar o PDF do orçamento' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", Promise)
], QuotesController.prototype, "downloadPdf", null);
__decorate([
    (0, common_1.Put)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Atualizar orçamento' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, quote_dto_1.UpdateQuoteDto]),
    __metadata("design:returntype", void 0)
], QuotesController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Excluir orçamento' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], QuotesController.prototype, "remove", null);
exports.QuotesController = QuotesController = __decorate([
    (0, swagger_1.ApiTags)('Quotes'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('quotes'),
    __metadata("design:paramtypes", [quotes_service_1.QuotesService])
], QuotesController);
//# sourceMappingURL=quotes.controller.js.map