import { ServiceUnavailableException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleTokenVerifier } from './google-token-verifier.service';

describe('GoogleTokenVerifier', () => {
  it('rejects when Google auth is disabled', async () => {
    const service = new GoogleTokenVerifier({ get: () => false } as unknown as ConfigService);
    await expect(service.verify('token')).rejects.toBeInstanceOf(ServiceUnavailableException);
  });

  it('rejects an invalid token', async () => {
    const config = {
      get: (key: string) => (key === 'GOOGLE_AUTH_ENABLED' ? true : 'client-id'),
    } as unknown as ConfigService;
    const service = new GoogleTokenVerifier(config);
    (service as any).client.verifyIdToken = jest.fn().mockRejectedValue(new Error('invalid'));
    await expect(service.verify('invalid')).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('returns a verified identity from a valid Google payload', async () => {
    const config = {
      get: (key: string) => (key === 'GOOGLE_AUTH_ENABLED' ? true : 'client-id'),
    } as unknown as ConfigService;
    const service = new GoogleTokenVerifier(config);
    (service as any).client.verifyIdToken = jest.fn().mockResolvedValue({
      getPayload: () => ({
        sub: 'google-sub',
        email: 'USER@example.com',
        email_verified: true,
        iss: 'https://accounts.google.com',
        name: 'User',
      }),
    });
    await expect(service.verify('valid')).resolves.toEqual({
      subject: 'google-sub',
      email: 'user@example.com',
      name: 'User',
    });
  });
});
