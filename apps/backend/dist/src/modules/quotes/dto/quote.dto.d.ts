import { QuoteStatus } from '@prisma/client';
export declare class QuoteItemDto {
    description: string;
    quantity: number;
    unitPrice: number;
}
export declare class CreateQuoteDto {
    clientId: string;
    discount?: number;
    notes?: string;
    status?: QuoteStatus;
    items: QuoteItemDto[];
}
export declare class UpdateQuoteDto extends CreateQuoteDto {
}
