import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import { QuoteStatus } from '@prisma/client';

export class QuoteItemDto {
  @ApiProperty({ example: 'Desenvolvimento Web' })
  @IsString()
  @IsNotEmpty()
  description: string;

  @ApiProperty({ example: 1 })
  @IsNumber()
  @Min(1)
  quantity: number;

  @ApiProperty({ example: 1500.0 })
  @IsNumber()
  @Min(0)
  unitPrice: number;
}

export class CreateQuoteDto {
  @ApiProperty({ example: 'client-uuid-123' })
  @IsString()
  @IsNotEmpty({ message: 'O cliente é obrigatório' })
  clientId: string;

  @ApiProperty({ example: 100.0, required: false })
  @IsNumber()
  @IsOptional()
  discount?: number;

  @ApiProperty({ example: 'Validade de 15 dias', required: false })
  @IsString()
  @IsOptional()
  notes?: string;

  @ApiProperty({ enum: QuoteStatus, default: QuoteStatus.DRAFT, required: false })
  @IsEnum(QuoteStatus)
  @IsOptional()
  status?: QuoteStatus;

  @ApiProperty({ type: [QuoteItemDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => QuoteItemDto)
  items: QuoteItemDto[];
}

export class UpdateQuoteDto extends CreateQuoteDto {}
