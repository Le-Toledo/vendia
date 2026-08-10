import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { FinanceType } from '@prisma/client';

export class CreateFinanceEntryDto {
  @ApiProperty({ example: 'Pagamento Projeto App Mobile' })
  @IsString()
  @IsNotEmpty({ message: 'A descrição da entrada/saída é obrigatória' })
  description: string;

  @ApiProperty({ example: 2500.0 })
  @IsNumber()
  @Min(0.01, { message: 'O valor deve ser maior que zero' })
  amount: number;

  @ApiProperty({ enum: FinanceType, example: FinanceType.INCOME })
  @IsEnum(FinanceType)
  type: FinanceType;

  @ApiProperty({ example: 'category-uuid-123', required: false })
  @IsString()
  @IsOptional()
  categoryId?: string;

  @ApiProperty({ example: '2026-08-01T00:00:00.000Z', required: false })
  @IsString()
  @IsOptional()
  entryDate?: string;

  @ApiProperty({ example: 'Pagamento via PIX em 2x', required: false })
  @IsString()
  @IsOptional()
  notes?: string;
}

export class CreateCategoryDto {
  @ApiProperty({ example: 'Consultoria Especializada' })
  @IsString()
  @IsNotEmpty({ message: 'O nome da categoria é obrigatório' })
  name: string;

  @ApiProperty({ enum: FinanceType, example: FinanceType.INCOME })
  @IsEnum(FinanceType)
  type: FinanceType;

  @ApiProperty({ example: '#10B981', required: false })
  @IsString()
  @IsOptional()
  colorHex?: string;
}

export class UpdateFinanceEntryDto extends CreateFinanceEntryDto {}
