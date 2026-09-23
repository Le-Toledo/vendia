import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { createHash, generateKeyPairSync } from 'crypto';
import { UnauthorizedException } from '@nestjs/common';
import { AppleAuthService } from './apple-auth.service';

describe('Apple authentication', () => {
  const jwt = new JwtService();
  const rsa = generateKeyPairSync('rsa', { modulusLength: 2048 });
  const ec = generateKeyPairSync('ec', { namedCurve: 'prime256v1' });
  const nonce = 'a'.repeat(64);
  const config = new ConfigService({
    APPLE_AUTH_ENABLED: true,
    APPLE_CLIENT_ID: 'com.example.vendeaiMobile',
    APPLE_TEAM_ID: 'TESTTEAM',
    APPLE_KEY_ID: 'TESTKEY',
    APPLE_PRIVATE_KEY: ec.privateKey.export({ type: 'pkcs8', format: 'pem' }).toString(),
    APPLE_TOKEN_ENCRYPTION_KEY: '01'.repeat(32),
  });
  const service = new AppleAuthService(config, jwt);
  function mockApple(audience = 'com.example.vendeaiMobile') {
    const idToken = jwt.sign(
      {
        sub: 'apple-user',
        email: 'private@example.com',
        email_verified: true,
        nonce: createHash('sha256').update(nonce).digest('hex'),
      },
      {
        privateKey: rsa.privateKey.export({ type: 'pkcs8', format: 'pem' }),
        algorithm: 'RS256',
        keyid: 'test-key',
        issuer: 'https://appleid.apple.com',
        audience,
        expiresIn: '5m',
      },
    );
    return jest
      .spyOn(global, 'fetch')
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({ id_token: idToken, refresh_token: 'test-refresh-token' }),
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          keys: [{ ...rsa.publicKey.export({ format: 'jwk' }), kid: 'test-key' }],
        }),
      } as Response);
  }
  afterEach(() => jest.restoreAllMocks());
  it('validates signature, audience and nonce; stores encrypted refresh and supports revocation', async () => {
    const fetchMock = mockApple();
    const identity = await service.authenticate('test-code', nonce);
    expect(identity.subject).toBe('apple-user');
    expect(identity.encryptedRefreshToken).not.toContain('test-refresh-token');
    fetchMock.mockResolvedValueOnce({ ok: true } as Response);
    await service.revoke(identity.encryptedRefreshToken);
    const body = fetchMock.mock.calls[2][1]!.body as URLSearchParams;
    expect(body.get('token')).toBe('test-refresh-token');
    expect(fetchMock.mock.calls[2][0]).toBe('https://appleid.apple.com/auth/revoke');
  });
  it('rejects tokens for a different app', async () => {
    mockApple('other-app');
    await expect(service.authenticate('test-code', nonce)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });
  it('rejects a mismatched nonce', async () => {
    mockApple();
    await expect(service.authenticate('test-code', 'b'.repeat(64))).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });
});
