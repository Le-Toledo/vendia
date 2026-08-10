import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateClientDto {
  @ApiProperty({ example: 'João Pereira', description: 'Nome ou razão social' })
  @IsString()
  @IsNotEmpty({ message: 'O nome do cliente é obrigatório' })
  name: string;

  @ApiProperty({ example: 'Pereira & Cia Ltda', required: false })
  @IsString()
  @IsOptional()
  companyName?: string;

  @ApiProperty({ example: 'joao@pereira.com.br', required: false })
  @IsEmail({}, { message: 'Forneça um e-mail válido' })
  @IsOptional()
  email?: string;

  @ApiProperty({ example: '(11) 98888-7777', required: false })
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiProperty({ example: '123.456.789-00', required: false })
  @IsString()
  @IsOptional()
  cpfCnpj?: string;

  @ApiProperty({ example: 'Rua Augusta, 1500 - SP', required: false })
  @IsString()
  @IsOptional()
  address?: string;

  @ApiProperty({ example: 'Cliente prefere atendimento por WhatsApp', required: false })
  @IsString()
  @IsOptional()
  notes?: string;
}

export class UpdateClientDto extends CreateClientDto {}
