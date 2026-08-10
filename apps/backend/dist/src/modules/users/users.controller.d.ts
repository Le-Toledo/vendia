import { UsersService } from './users.service';
import { UpdateProfileDto, UpdateSettingsDto } from './dto/user.dto';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    getProfile(user: any): Promise<{
        id: string;
        email: string;
        role: import(".prisma/client").$Enums.Role;
        createdAt: Date;
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
        settings: {
            id: string;
            updatedAt: Date;
            userId: string;
            themeMode: string;
            language: string;
            emailNotify: boolean;
            aiProvider: string;
        };
    }>;
    updateProfile(user: any, dto: UpdateProfileDto): Promise<{
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
    }>;
    updateSettings(user: any, dto: UpdateSettingsDto): Promise<{
        id: string;
        updatedAt: Date;
        userId: string;
        themeMode: string;
        language: string;
        emailNotify: boolean;
        aiProvider: string;
    }>;
}
