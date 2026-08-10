import { Strategy } from 'passport-jwt';
import { PrismaService } from '../../../common/prisma/prisma.service';
declare const JwtStrategy_base: new (...args: any[]) => Strategy;
export declare class JwtStrategy extends JwtStrategy_base {
    private readonly prisma;
    constructor(prisma: PrismaService);
    validate(payload: {
        sub: string;
        email: string;
    }): Promise<{
        id: string;
        email: string;
        role: import(".prisma/client").$Enums.Role;
        profile: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            fullName: string;
            companyName: string | null;
            cpfCnpj: string | null;
            phone: string | null;
            avatarUrl: string | null;
            logoUrl: string | null;
            address: string | null;
            city: string | null;
            state: string | null;
            zipCode: string | null;
            userId: string;
        };
    }>;
}
export {};
