import { ContractsService } from './contracts.service';
import { CreateContractDto, UpdateContractDto } from './dto/contract.dto';
export declare class ContractsController {
    private readonly contractsService;
    constructor(contractsService: ContractsService);
    create(user: any, dto: CreateContractDto): Promise<{
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
    update(user: any, id: string, dto: UpdateContractDto): Promise<{
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
    remove(user: any, id: string): Promise<{
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
