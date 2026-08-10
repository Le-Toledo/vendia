import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../common/prisma/prisma.service';
import { LoginDto, RegisterDto, RefreshTokenDto, GoogleAuthDto } from './dto/auth.dto';
export declare class AuthService {
    private readonly prisma;
    private readonly jwtService;
    constructor(prisma: PrismaService, jwtService: JwtService);
    register(dto: RegisterDto): Promise<{
        user: {
            id: string;
            email: string;
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
        };
        tokens: {
            accessToken: string;
            refreshToken: string;
        };
    }>;
    login(dto: LoginDto): Promise<{
        user: {
            id: string;
            email: string;
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
        };
        tokens: {
            accessToken: string;
            refreshToken: string;
        };
    }>;
    googleAuth(dto: GoogleAuthDto): Promise<{
        user: {
            id: string;
            email: string;
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
        };
        tokens: {
            accessToken: string;
            refreshToken: string;
        };
    }>;
    refreshToken(dto: RefreshTokenDto): Promise<{
        accessToken: string;
        refreshToken: string;
    }>;
    logout(userId: string): Promise<{
        message: string;
    }>;
    private generateTokens;
    private updateRefreshToken;
}
