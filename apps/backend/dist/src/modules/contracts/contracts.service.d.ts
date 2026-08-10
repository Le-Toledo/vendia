import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateContractDto, UpdateContractDto } from './dto/contract.dto';
export declare class ContractsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    create(userId: string, dto: CreateContractDto): Promise<{
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
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        status: import(".prisma/client").$Enums.ContractStatus;
        clientId: string;
        title: string;
        content: string;
        value: number;
        startDate: Date | null;
        endDate: Date | null;
        pdfUrl: string | null;
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
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        status: import(".prisma/client").$Enums.ContractStatus;
        clientId: string;
        title: string;
        content: string;
        value: number;
        startDate: Date | null;
        endDate: Date | null;
        pdfUrl: string | null;
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
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        status: import(".prisma/client").$Enums.ContractStatus;
        clientId: string;
        title: string;
        content: string;
        value: number;
        startDate: Date | null;
        endDate: Date | null;
        pdfUrl: string | null;
    }>;
    update(userId: string, id: string, dto: UpdateContractDto): Promise<{
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
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        status: import(".prisma/client").$Enums.ContractStatus;
        clientId: string;
        title: string;
        content: string;
        value: number;
        startDate: Date | null;
        endDate: Date | null;
        pdfUrl: string | null;
    }>;
    remove(userId: string, id: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        status: import(".prisma/client").$Enums.ContractStatus;
        clientId: string;
        title: string;
        content: string;
        value: number;
        startDate: Date | null;
        endDate: Date | null;
        pdfUrl: string | null;
    }>;
}
