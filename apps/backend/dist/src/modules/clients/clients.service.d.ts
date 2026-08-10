import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateClientDto, UpdateClientDto } from './dto/client.dto';
export declare class ClientsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    create(userId: string, dto: CreateClientDto): Promise<{
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
    }>;
    findAll(userId: string, search?: string): Promise<({
        _count: {
            quotes: number;
            contracts: number;
        };
    } & {
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
    })[]>;
    findOne(userId: string, id: string): Promise<{
        quotes: {
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
        }[];
        contracts: {
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
        }[];
    } & {
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
    }>;
    update(userId: string, id: string, dto: UpdateClientDto): Promise<{
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
    }>;
    remove(userId: string, id: string): Promise<{
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
    }>;
}
