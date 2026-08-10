import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class UpdateProfileDto {
  @ApiProperty({ example: 'Carlos Eduardo Silva', required: false })
  @IsString()
  @IsOptional()
  fullName?: string;

  @ApiProperty({ example: 'Silva Tech Services Ltda', required: false })
  @IsString()
  @IsOptional()
  companyName?: string;

  @ApiProperty({ example: '12.345.678/0001-90', required: false })
  @IsString()
  @IsOptional()
  cpfCnpj?: string;

  @ApiProperty({ example: '(11) 98765-4321', required: false })
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiProperty({ example: 'https://storage.vendeai.com/logo.png', required: false })
  @IsString()
  @IsOptional()
  logoUrl?: string;

  @ApiProperty({ example: 'https://storage.vendeai.com/avatar.jpg', required: false })
  @IsString()
  @IsOptional()
  avatarUrl?: string;

  @ApiProperty({ example: 'Av. Paulista, 1000', required: false })
  @IsString()
  @IsOptional()
  address?: string;

  @ApiProperty({ example: 'São Paulo', required: false })
  @IsString()
  @IsOptional()
  city?: string;

  @ApiProperty({ example: 'SP', required: false })
  @IsString()
  @IsOptional()
  state?: string;

  @ApiProperty({ example: '01310-100', required: false })
  @IsString()
  @IsOptional()
  zipCode?: string;
}

export class UpdateSettingsDto {
  @ApiProperty({ example: 'dark', enum: ['light', 'dark', 'system'], required: false })
  @IsString()
  @IsOptional()
  themeMode?: string;

  @ApiProperty({ example: 'pt-BR', required: false })
  @IsString()
  @IsOptional()
  language?: string;

  @ApiProperty({ example: 'openai', required: false })
  @IsString()
  @IsOptional()
  aiProvider?: string;
}
