export declare class CreateClientDto {
    name: string;
    companyName?: string;
    email?: string;
    phone?: string;
    cpfCnpj?: string;
    address?: string;
    notes?: string;
}
export declare class UpdateClientDto extends CreateClientDto {
}
