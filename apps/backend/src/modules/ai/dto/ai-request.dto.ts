import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class ChatAiDto {
  @ApiProperty({ example: 'Crie um orçamento para desenvolvimento de site no valor de R$ 2500' })
  @IsString()
  @IsNotEmpty({ message: 'A mensagem do prompt é obrigatória' })
  message: string;

  @ApiProperty({ example: 'client-uuid-123', required: false })
  @IsString()
  @IsOptional()
  clientId?: string;
}

export class GenerateMarketingCopyDto {
  @ApiProperty({
    example: 'Post Instagram',
    description: 'Canal: Instagram, Facebook, WhatsApp, Mercado Livre, Shopee, Amazon, Ads',
  })
  @IsString()
  @IsNotEmpty()
  targetChannel: string;

  @ApiProperty({ example: 'Manutenção de Computadores e Notebooks' })
  @IsString()
  @IsNotEmpty()
  productOrService: string;

  @ApiProperty({ example: 'Desconto de 20% para primeiros clientes', required: false })
  @IsString()
  @IsOptional()
  details?: string;
}
