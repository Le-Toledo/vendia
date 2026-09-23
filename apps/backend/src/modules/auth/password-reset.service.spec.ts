import { ConfigService } from '@nestjs/config';
import { BadRequestException, ServiceUnavailableException } from '@nestjs/common';
import { createHash } from 'crypto';
import { PasswordResetService } from './password-reset.service';
import { PrismaService } from '../../common/prisma/prisma.service';

describe('PasswordResetService', () => {
  const user = { id: 'u1', email: 'user@example.com', passwordHash: 'hash', isActive: true };
  let prisma: { user: { findUnique: jest.Mock; updateMany: jest.Mock } };
  let service: PasswordResetService;
  beforeEach(() => {
    prisma = {
      user: {
        findUnique: jest.fn().mockResolvedValue(user),
        updateMany: jest.fn().mockResolvedValue({ count: 1 }),
      },
    };
    service = new PasswordResetService(
      prisma as unknown as PrismaService,
      new ConfigService({ RESEND_API_KEY: 'test-only-key', MAIL_FROM: 'test@example.com' }),
    );
  });
  afterEach(() => jest.restoreAllMocks());
  it('sends an opaque single-use code and stores only its hash', async () => {
    const send = jest.spyOn(global, 'fetch').mockResolvedValue({ ok: true } as Response);
    await service.request(user.email);
    const payload = JSON.parse(send.mock.calls[0][1]!.body as string);
    const code = payload.text.match(/[a-f0-9]{48}/)[0];
    const update = prisma.user.updateMany.mock.calls[0][0];
    expect(update.data.passwordResetHash).toBe(createHash('sha256').update(code).digest('hex'));
    expect(update.data.passwordResetExpiresAt.getTime() - Date.now()).toBeGreaterThan(14 * 60_000);
    expect(JSON.stringify(update)).not.toContain(code);
  });
  it('does not disclose unknown accounts or send an email to them', async () => {
    const send = jest.spyOn(global, 'fetch').mockResolvedValue({ ok: true } as Response);
    const known = await service.request(user.email);
    prisma.user.findUnique.mockResolvedValue(null);
    expect(await service.request('unknown@example.com')).toEqual(known);
    expect(send).toHaveBeenCalledTimes(1);
  });
  it('enforces the per-account cooldown', async () => {
    prisma.user.updateMany.mockResolvedValue({ count: 0 });
    const send = jest.spyOn(global, 'fetch');
    await service.request(user.email);
    expect(send).not.toHaveBeenCalled();
  });
  it('reports unavailable email configuration rather than pretending delivery', async () => {
    const unavailable = new PasswordResetService(
      prisma as unknown as PrismaService,
      new ConfigService(),
    );
    await expect(unavailable.request(user.email)).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });
  it('rejects expired/used codes and invalidates sessions only on an atomic match', async () => {
    prisma.user.updateMany.mockResolvedValue({ count: 0 });
    await expect(
      service.reset(user.email, 'a'.repeat(48), 'StrongPassword1!'),
    ).rejects.toBeInstanceOf(BadRequestException);
    const update = prisma.user.updateMany.mock.calls[0][0];
    expect(update.where.passwordResetExpiresAt.gt).toBeInstanceOf(Date);
    expect(update.data.passwordResetHash).toBeNull();
    expect(update.data.refreshToken).toBeNull();
    expect(update.data.sessionVersion).toEqual({ increment: 1 });
  });
});
