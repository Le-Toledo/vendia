import { FinanceType } from '@prisma/client';
export declare class CreateFinanceEntryDto {
    description: string;
    amount: number;
    type: FinanceType;
    categoryId?: string;
    entryDate?: string;
    notes?: string;
}
export declare class CreateCategoryDto {
    name: string;
    type: FinanceType;
    colorHex?: string;
}
export declare class UpdateFinanceEntryDto extends CreateFinanceEntryDto {
}
