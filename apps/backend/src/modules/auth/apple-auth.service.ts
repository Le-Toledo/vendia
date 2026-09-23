import { Injectable, ServiceUnavailableException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import {
  createCipheriv,
  createDecipheriv,
  createHash,
  createPublicKey,
  randomBytes,
  JsonWebKey,
} from 'crypto';

@Injectable()
export class AppleAuthService {
  constructor(
    private readonly config: ConfigService,
    private readonly jwt: JwtService,
  ) {}

  private clientSecret() {
    if (!this.config.get<boolean>('APPLE_AUTH_ENABLED'))
      throw new ServiceUnavailableException('Login Apple não habilitado.');
    const privateKey = this.config.getOrThrow<string>('APPLE_PRIVATE_KEY').replace(/\\n/g, '\n');
    return this.jwt.sign(
      {},
      {
        algorithm: 'ES256',
        privateKey,
        keyid: this.config.getOrThrow<string>('APPLE_KEY_ID'),
        issuer: this.config.getOrThrow<string>('APPLE_TEAM_ID'),
        audience: 'https://appleid.apple.com',
        subject: this.config.getOrThrow<string>('APPLE_CLIENT_ID'),
        expiresIn: '5m',
      },
    );
  }

  private async post(path: string, fields: Record<string, string>) {
    const response = await fetch(`https://appleid.apple.com/auth/${path}`, {
      method: 'POST',
      signal: AbortSignal.timeout(15_000),
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: this.config.getOrThrow<string>('APPLE_CLIENT_ID'),
        client_secret: this.clientSecret(),
        ...fields,
      }),
    });
    if (!response.ok)
      throw new UnauthorizedException('Não foi possível validar a autorização Apple.');
    return response;
  }

  async authenticate(code: string, nonce: string) {
    try {
      const response = await this.post('token', { code, grant_type: 'authorization_code' });
      const tokens = (await response.json()) as { id_token?: string; refresh_token?: string };
      if (!tokens.id_token || !tokens.refresh_token) throw new Error('Missing tokens');
      const decoded = this.jwt.decode(tokens.id_token, { complete: true }) as {
        header: { kid: string };
      } | null;
      if (!decoded?.header?.kid) throw new Error('Missing key');
      const keysResponse = await fetch('https://appleid.apple.com/auth/keys', {
        signal: AbortSignal.timeout(15_000),
      });
      if (!keysResponse.ok) throw new Error('Keys unavailable');
      const keys = (await keysResponse.json()) as { keys: (JsonWebKey & { kid: string })[] };
      const key = keys.keys.find((item) => item.kid === decoded.header.kid);
      if (!key || key.kty !== 'RSA') throw new Error('Invalid key');
      const publicKey = createPublicKey({ key, format: 'jwk' }).export({
        type: 'spki',
        format: 'pem',
      });
      const payload = await this.jwt.verifyAsync(tokens.id_token, {
        publicKey,
        algorithms: ['RS256'],
        issuer: 'https://appleid.apple.com',
        audience: this.config.getOrThrow<string>('APPLE_CLIENT_ID'),
      });
      if (
        typeof payload.sub !== 'string' ||
        typeof payload.email !== 'string' ||
        ![true, 'true'].includes(payload.email_verified) ||
        payload.nonce !== createHash('sha256').update(nonce).digest('hex')
      )
        throw new Error('Invalid identity');
      return {
        subject: payload.sub,
        email: payload.email.toLowerCase(),
        encryptedRefreshToken: this.encrypt(tokens.refresh_token),
      };
    } catch (error) {
      if (error instanceof ServiceUnavailableException) throw error;
      throw new UnauthorizedException('Não foi possível entrar com Apple. Tente novamente.');
    }
  }

  async validateStoredAuthorization(encrypted: string) {
    await this.post('token', {
      refresh_token: this.decrypt(encrypted),
      grant_type: 'refresh_token',
    });
  }

  async revoke(encrypted: string) {
    try {
      await this.post('revoke', {
        token: this.decrypt(encrypted),
        token_type_hint: 'refresh_token',
      });
    } catch {
      throw new ServiceUnavailableException(
        'Não foi possível revogar a autorização Apple. Tente excluir a conta novamente.',
      );
    }
  }

  private encrypt(token: string) {
    const iv = randomBytes(12);
    const cipher = createCipheriv(
      'aes-256-gcm',
      Buffer.from(this.config.getOrThrow<string>('APPLE_TOKEN_ENCRYPTION_KEY'), 'hex'),
      iv,
    );
    const encrypted = Buffer.concat([cipher.update(token, 'utf8'), cipher.final()]);
    return [iv, cipher.getAuthTag(), encrypted].map((value) => value.toString('base64')).join('.');
  }
  private decrypt(value: string) {
    const [iv, tag, encrypted] = value.split('.').map((part) => Buffer.from(part, 'base64'));
    const decipher = createDecipheriv(
      'aes-256-gcm',
      Buffer.from(this.config.getOrThrow<string>('APPLE_TOKEN_ENCRYPTION_KEY'), 'hex'),
      iv,
    );
    decipher.setAuthTag(tag);
    return Buffer.concat([decipher.update(encrypted), decipher.final()]).toString('utf8');
  }
}
