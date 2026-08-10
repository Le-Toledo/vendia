import { ContractStatus } from '@prisma/client';
export declare class CreateContractDto {
    clientId: string;
    title: string;
    content: string;
    value: number;
    status?: ContractStatus;
}
export declare class GenerateContractAiDto {
    clientId: string;
    promptInstructions: string;
}
export declare class UpdateContractDto extends CreateContractDto {
}
