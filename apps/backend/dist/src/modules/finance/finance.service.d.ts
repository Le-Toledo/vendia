import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateFinanceEntryDto, CreateCategoryDto } from './dto/finance.dto';
import { FinanceType } from '@prisma/client';
export declare class FinanceService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    createEntry(userId: string, dto: CreateFinanceEntryDto): Promise<{
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
    findAllEntries(userId: string, type?: FinanceType, month?: number, year?: number): Promise<({
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
    getSummary(userId: string): Promise<{
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
    createCategory(userId: string, dto: CreateCategoryDto): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        name: string;
        type: import(".prisma/client").$Enums.FinanceType;
        colorHex: string | null;
    }>;
    getCategories(userId: string, type?: FinanceType): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        name: string;
        type: import(".prisma/client").$Enums.FinanceType;
        colorHex: string | null;
    }[]>;
    deleteEntry(userId: string, id: string): Promise<{
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
