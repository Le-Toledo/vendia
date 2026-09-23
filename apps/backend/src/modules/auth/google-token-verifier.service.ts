import { Injectable, ServiceUnavailableException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { OAuth2Client } from 'google-auth-library';

export interface VerifiedGoogleIdentity {
  subject: string;
  email: string;
  name: string;
}

@Injectable()
export class GoogleTokenVerifier {
  private readonly client = new OAuth2Client();

  constructor(private readonly config: ConfigService) {}

  async verify(idToken: string): Promise<VerifiedGoogleIdentity> {
    if (!this.config.get<boolean>('GOOGLE_AUTH_ENABLED')) {
      throw new ServiceUnavailableException('Login com Google não está habilitado');
    }
    const audience = this.config.get<string>('GOOGLE_CLIENT_ID');
    if (!audience) throw new ServiceUnavailableException('Login com Google não está configurado');

    try {
      const ticket = await this.client.verifyIdToken({ idToken, audience });
      const payload = ticket.getPayload();
      if (
        !payload?.sub ||
        !payload.email ||
        !payload.email_verified ||
        !payload.iss ||
        !['accounts.google.com', 'https://accounts.google.com'].includes(payload.iss)
      ) {
        throw new UnauthorizedException('Token do Google inválido');
      }
      return {
        subject: payload.sub,
        email: payload.email.toLowerCase(),
        name: payload.name?.trim() || payload.email.split('@')[0],
      };
    } catch (error) {
      if (error instanceof ServiceUnavailableException || error instanceof UnauthorizedException)
        throw error;
      throw new UnauthorizedException('Token do Google inválido ou expirado');
    }
  }
}
