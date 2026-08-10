import { FinanceService } from './finance.service';
import { CreateFinanceEntryDto, CreateCategoryDto } from './dto/finance.dto';
import { FinanceType } from '@prisma/client';
export declare class FinanceController {
    private readonly financeService;
    constructor(financeService: FinanceService);
    createEntry(user: any, dto: CreateFinanceEntryDto): Promise<{
        category: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            name: string;
            type: import(".prisma/client").$Enums.FinanceType;
            colorHex: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        type: import(".prisma/client").$Enums.FinanceType;
        notes: string | null;
        description: string;
        amount: number;
        categoryId: string | null;
        entryDate: Date;
    }>;
    findAllEntries(user: any, type?: FinanceType, month?: string, year?: string): Promise<({
        category: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            name: string;
            type: import(".prisma/client").$Enums.FinanceType;
            colorHex: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        type: import(".prisma/client").$Enums.FinanceType;
        notes: string | null;
        description: string;
        amount: number;
        categoryId: string | null;
        entryDate: Date;
    })[]>;
    getSummary(user: any): Promise<{
        financial: {
            totalIncome: number;
            totalExpense: number;
            balance: number;
        };
        metrics: {
            clientCount: number;
            quoteCount: number;
            contractCount: number;
        };
        recentActivities: ({
            category: {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                userId: string;
                name: string;
                type: import(".prisma/client").$Enums.FinanceType;
                colorHex: string | null;
            };
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            type: import(".prisma/client").$Enums.FinanceType;
            notes: string | null;
            description: string;
            amount: number;
            categoryId: string | null;
            entryDate: Date;
        })[];
    }>;
    createCategory(user: any, dto: CreateCategoryDto): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        name: string;
        type: import(".prisma/client").$Enums.FinanceType;
        colorHex: string | null;
    }>;
    getCategories(user: any, type?: FinanceType): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        name: string;
        type: import(".prisma/client").$Enums.FinanceType;
        colorHex: string | null;
    }[]>;
    deleteEntry(user: any, id: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        type: import(".prisma/client").$Enums.FinanceType;
        notes: string | null;
        description: string;
        amount: number;
        categoryId: string | null;
        entryDate: Date;
    }>;
}
