import { Controller, Post, Body, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { PasswordResetService } from './password-reset.service';
import { ForgotPasswordDto, ResetPasswordDto, AppleAuthDto } from './dto/auth.dto';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, RefreshTokenDto, GoogleAuthDto } from './dto/auth.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly passwordReset: PasswordResetService,
  ) {}

  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  forgotPassword(@Body() dto: ForgotPasswordDto) {
    return this.passwordReset.request(dto.email);
  }

  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  resetPassword(@Body() dto: ResetPasswordDto) {
    return this.passwordReset.reset(dto.email, dto.token, dto.password);
  }

  @Post('register')
  @ApiOperation({ summary: 'Criar nova conta de usuário' })
  @ApiResponse({ status: 201, description: 'Usuário registrado com sucesso' })
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Autenticar com e-mail e senha' })
  @ApiResponse({ status: 200, description: 'Login bem sucedido com tokens JWT' })
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('google')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Autenticar via Google OAuth' })
  googleAuth(@Body() dto: GoogleAuthDto) {
    return this.authService.googleAuth(dto);
  }

  @Post('apple')
  @HttpCode(HttpStatus.OK)
  appleAuth(@Body() dto: AppleAuthDto) {
    return this.authService.appleAuth(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Renovar Access Token utilizando Refresh Token' })
  refreshToken(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshToken(dto);
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Encerrar sessão ativa' })
  logout(@CurrentUser() user: any) {
    return this.authService.logout(user.id);
  }
}
