"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PdfService = void 0;
const common_1 = require("@nestjs/common");
const PDFDocument = require("pdfkit");
let PdfService = class PdfService {
    async generateQuotePdf(quote) {
        return new Promise((resolve, reject) => {
            const doc = new PDFDocument({ margin: 50 });
            const buffers = [];
            doc.on('data', (buffer) => buffers.push(buffer));
            doc.on('end', () => resolve(Buffer.concat(buffers)));
            doc.on('error', (err) => reject(err));
            doc.fontSize(22).fillColor('#1E293B').text('VENDEAI - ORÇAMENTO', { align: 'center' });
            doc.moveDown();
            doc.fontSize(12).fillColor('#64748B').text(`Código: ${quote.codeNumber}`, { align: 'right' });
            doc.text(`Data: ${new Date(quote.createdAt).toLocaleDateString('pt-BR')}`, { align: 'right' });
            doc.moveDown();
            doc.fontSize(14).fillColor('#0F172A').text('DADOS DO CLIENTE', { underline: true });
            doc.fontSize(10).fillColor('#334155');
            doc.text(`Cliente: ${quote.client?.name || 'N/A'}`);
            if (quote.client?.companyName)
                doc.text(`Empresa: ${quote.client.companyName}`);
            if (quote.client?.cpfCnpj)
                doc.text(`CPF/CNPJ: ${quote.client.cpfCnpj}`);
            if (quote.client?.email)
                doc.text(`E-mail: ${quote.client.email}`);
            if (quote.client?.phone)
                doc.text(`Telefone: ${quote.client.phone}`);
            doc.moveDown();
            doc.fontSize(14).fillColor('#0F172A').text('ITENS DO ORÇAMENTO', { underline: true });
            doc.moveDown(0.5);
            quote.items?.forEach((item, index) => {
                const itemTotal = (item.quantity * item.unitPrice).toFixed(2);
                doc.fontSize(10).fillColor('#1E293B').text(`${index + 1}. ${item.description} - Qtd: ${item.quantity} x R$ ${item.unitPrice.toFixed(2)} = R$ ${itemTotal}`);
            });
            doc.moveDown();
            doc.fontSize(12).fillColor('#0F172A');
            doc.text(`Subtotal: R$ ${quote.subtotal.toFixed(2)}`, { align: 'right' });
            doc.text(`Desconto: R$ ${quote.discount.toFixed(2)}`, { align: 'right' });
            doc.fontSize(14).fillColor('#10B981').text(`TOTAL: R$ ${quote.total.toFixed(2)}`, { align: 'right' });
            if (quote.notes) {
                doc.moveDown();
                doc.fontSize(10).fillColor('#64748B').text(`Observações: ${quote.notes}`);
            }
            doc.end();
        });
    }
};
exports.PdfService = PdfService;
exports.PdfService = PdfService = __decorate([
    (0, common_1.Injectable)()
], PdfService);
//# sourceMappingURL=pdf.service.js.map