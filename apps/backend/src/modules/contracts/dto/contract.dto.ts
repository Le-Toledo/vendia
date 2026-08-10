import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { ContractStatus } from '@prisma/client';

export class CreateContractDto {
  @ApiProperty({ example: 'client-uuid-123' })
  @IsString()
  @IsNotEmpty({ message: 'O cliente é obrigatório' })
  clientId: string;

  @ApiProperty({ example: 'Contrato de Prestação de Serviços de TI' })
  @IsString()
  @IsNotEmpty({ message: 'O título do contrato é obrigatório' })
  title: string;

  @ApiProperty({ example: 'Cláusula 1: O prestador compromete-se a...' })
  @IsString()
  @IsNotEmpty({ message: 'O conteúdo do contrato é obrigatório' })
  content: string;

  @ApiProperty({ example: 5000.0 })
  @IsNumber()
  @Min(0)
  value: number;

  @ApiProperty({ enum: ContractStatus, default: ContractStatus.DRAFT, required: false })
  @IsEnum(ContractStatus)
  @IsOptional()
  status?: ContractStatus;
}

export class GenerateContractAiDto {
  @ApiProperty({ example: 'client-uuid-123' })
  @IsString()
  @IsNotEmpty()
  clientId: string;

  @ApiProperty({ example: 'Prestação de serviço de desenvolvimento de software mobile no valor de R$ 5.000 com prazo de 30 dias.' })
  @IsString()
  @IsNotEmpty()
  promptInstructions: string;
}

export class UpdateContractDto extends CreateContractDto {}
