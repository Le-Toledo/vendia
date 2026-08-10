import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateQuoteDto, UpdateQuoteDto } from './dto/quote.dto';
import { PdfService } from './pdf.service';
export declare class QuotesService {
    private readonly prisma;
    private readonly pdfService;
    constructor(prisma: PrismaService, pdfService: PdfService);
    create(userId: string, dto: CreateQuoteDto): Promise<{
        client: {
            id: string;
            email: string | null;
            createdAt: Date;
            updatedAt: Date;
            companyName: string | null;
            cpfCnpj: string | null;
            phone: string | null;
            address: string | null;
            userId: string;
            name: string;
            notes: string | null;
        };
        items: {
            id: string;
            description: string;
            quantity: number;
            unitPrice: number;
            totalPrice: number;
            quoteId: string;
        }[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        notes: string | null;
        codeNumber: string;
        status: import(".prisma/client").$Enums.QuoteStatus;
        subtotal: number;
        discount: number;
        total: number;
        validUntil: Date | null;
        clientId: string;
    }>;
    findAll(userId: string, status?: string): Promise<({
        client: {
            id: string;
            email: string | null;
            createdAt: Date;
            updatedAt: Date;
            companyName: string | null;
            cpfCnpj: string | null;
            phone: string | null;
            address: string | null;
            userId: string;
            name: string;
            notes: string | null;
        };
        items: {
            id: string;
            description: string;
            quantity: number;
            unitPrice: number;
            totalPrice: number;
            quoteId: string;
        }[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        notes: string | null;
        codeNumber: string;
        status: import(".prisma/client").$Enums.QuoteStatus;
        subtotal: number;
        discount: number;
        total: number;
        validUntil: Date | null;
        clientId: string;
    })[]>;
    findOne(userId: string, id: string): Promise<{
        client: {
            id: string;
            email: string | null;
            createdAt: Date;
            updatedAt: Date;
            companyName: string | null;
            cpfCnpj: string | null;
            phone: string | null;
            address: string | null;
            userId: string;
            name: string;
            notes: string | null;
        };
        items: {
            id: string;
            description: string;
            quantity: number;
            unitPrice: number;
            totalPrice: number;
            quoteId: string;
        }[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        notes: string | null;
        codeNumber: string;
        status: import(".prisma/client").$Enums.QuoteStatus;
        subtotal: number;
        discount: number;
        total: number;
        validUntil: Date | null;
        clientId: string;
    }>;
    update(userId: string, id: string, dto: UpdateQuoteDto): Promise<{
        client: {
            id: string;
            email: string | null;
            createdAt: Date;
            updatedAt: Date;
            companyName: string | null;
            cpfCnpj: string | null;
            phone: string | null;
            address: string | null;
            userId: string;
            name: string;
            notes: string | null;
        };
        items: {
            id: string;
            description: string;
            quantity: number;
            unitPrice: number;
            totalPrice: number;
            quoteId: string;
        }[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        notes: string | null;
        codeNumber: string;
        status: import(".prisma/client").$Enums.QuoteStatus;
        subtotal: number;
        discount: number;
        total: number;
        validUntil: Date | null;
        clientId: string;
    }>;
    duplicate(userId: string, id: string): Promise<{
        client: {
            id: string;
            email: string | null;
            createdAt: Date;
            updatedAt: Date;
            companyName: string | null;
            cpfCnpj: string | null;
            phone: string | null;
            address: string | null;
            userId: string;
            name: string;
            notes: string | null;
        };
        items: {
            id: string;
            description: string;
            quantity: number;
            unitPrice: number;
            totalPrice: number;
            quoteId: string;
        }[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        notes: string | null;
        codeNumber: string;
        status: import(".prisma/client").$Enums.QuoteStatus;
        subtotal: number;
        discount: number;
        total: number;
        validUntil: Date | null;
        clientId: string;
    }>;
    remove(userId: string, id: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        notes: string | null;
        codeNumber: string;
        status: import(".prisma/client").$Enums.QuoteStatus;
        subtotal: number;
        discount: number;
        total: number;
        validUntil: Date | null;
        clientId: string;
    }>;
    generatePdf(userId: string, id: string): Promise<Buffer>;
}
