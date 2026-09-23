import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MinLength,
  MaxLength,
} from 'class-validator';

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
  @MinLength(10, { message: 'A senha deve conter no mínimo 10 caracteres' })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/, {
    message: 'A senha deve conter letra maiúscula, minúscula e número',
  })
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

export class ForgotPasswordDto {
  @IsEmail()
  @MaxLength(254)
  email: string;
}
export class ResetPasswordDto extends ForgotPasswordDto {
  @IsString()
  @Matches(/^[a-f0-9]{48}$/)
  token: string;
  @IsString()
  @MinLength(10)
  @MaxLength(72)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/)
  password: string;
}

export class AppleAuthDto {
  @IsString() @IsNotEmpty() @MaxLength(4096) authorizationCode: string;
  @IsString() @Matches(/^[a-f0-9]{64}$/) nonce: string;
}
