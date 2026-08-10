export declare class RegisterDto {
    fullName: string;
    email: string;
    password: string;
    companyName?: string;
}
export declare class LoginDto {
    email: string;
    password: string;
}
export declare class RefreshTokenDto {
    refreshToken: string;
}
export declare class GoogleAuthDto {
    idToken: string;
}
