import { Response } from 'express';
import { QuotesService } from './quotes.service';
import { CreateQuoteDto, UpdateQuoteDto } from './dto/quote.dto';
export declare class QuotesController {
    private readonly quotesService;
    constructor(quotesService: QuotesService);
    create(user: any, dto: CreateQuoteDto): Promise<{
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
    findAll(user: any, status?: string): Promise<({
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
    findOne(user: any, id: string): Promise<{
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
    duplicate(user: any, id: string): Promise<{
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
    downloadPdf(user: any, id: string, res: Response): Promise<void>;
    update(user: any, id: string, dto: UpdateQuoteDto): Promise<{
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
    remove(user: any, id: string): Promise<{
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
}
