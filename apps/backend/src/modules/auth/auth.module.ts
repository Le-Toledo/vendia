import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AppleAuthService } from './apple-auth.service';
import { PasswordResetService } from './password-reset.service';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './strategies/jwt.strategy';
import { PrismaService } from '../../common/prisma/prisma.service';
import { GoogleTokenVerifier } from './google-token-verifier.service';

@Module({
  imports: [PassportModule, JwtModule.register({})],
  controllers: [AuthController],
  providers: [
    AppleAuthService,
    PasswordResetService,
    AuthService,
    JwtStrategy,
    PrismaService,
    GoogleTokenVerifier,
  ],
  exports: [AuthService, AppleAuthService],
})
export class AuthModule {}
