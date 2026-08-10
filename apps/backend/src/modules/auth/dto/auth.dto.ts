import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'João Silva', description: 'Nome completo do usuário' })
  @IsString()
  @IsNotEmpty({ message: 'O nome é obrigatório' })
  fullName: string;

  @ApiProperty({ example: 'joao@empresa.com.br', description: 'E-mail para login' })
  @IsEmail({}, { message: 'Forneça um e-mail válido' })
  email: string;

  @ApiProperty({ example: 'SenhaForte123!', description: 'Senha de acesso' })
  @IsString()
  @MinLength(6, { message: 'A senha deve conter no mínimo 6 caracteres' })
  password: string;

  @ApiProperty({ example: 'Silva Soluções MEI', required: false })
  @IsString()
  @IsOptional()
  companyName?: string;
}

export class LoginDto {
  @ApiProperty({ example: 'joao@empresa.com.br' })
  @IsEmail({}, { message: 'Forneça um e-mail válido' })
  email: string;

  @ApiProperty({ example: 'SenhaForte123!' })
  @IsString()
  @IsNotEmpty({ message: 'A senha é obrigatória' })
  password: string;
}

export class RefreshTokenDto {
  @ApiProperty({ description: 'Refresh Token de renovação de sessão' })
  @IsString()
  @IsNotEmpty({ message: 'O refresh token é obrigatório' })
  refreshToken: string;
}

export class GoogleAuthDto {
  @ApiProperty({ description: 'ID Token retornado pelo Google OAuth' })
  @IsString()
  @IsNotEmpty({ message: 'O idToken do Google é obrigatório' })
  idToken: string;
}
