import { ClientsService } from './clients.service';
import { CreateClientDto, UpdateClientDto } from './dto/client.dto';
export declare class ClientsController {
    private readonly clientsService;
    constructor(clientsService: ClientsService);
    create(user: any, dto: CreateClientDto): Promise<{
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
    findAll(user: any, search?: string): Promise<({
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
    findOne(user: any, id: string): Promise<{
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
    update(user: any, id: string, dto: UpdateClientDto): Promise<{
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
    remove(user: any, id: string): Promise<{
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
