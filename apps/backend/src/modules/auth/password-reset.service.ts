import {
  BadRequestException,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHash, randomBytes } from 'crypto';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../common/prisma/prisma.service';

const genericMessage = {
  message: 'Se houver uma conta elegível, você receberá um código de recuperação por email.',
};
@Injectable()
export class PasswordResetService {
  private readonly logger = new Logger(PasswordResetService.name);
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  async request(email: string) {
    const key = this.config.get<string>('RESEND_API_KEY');
    const from = this.config.get<string>('MAIL_FROM');
    if (!key || !from)
      throw new ServiceUnavailableException(
        'A recuperação por email está temporariamente indisponível.',
      );
    const user = await this.prisma.user.findUnique({
      where: { email: email.trim().toLowerCase() },
    });
    if (!user?.isActive || !user.passwordHash) return genericMessage;
    const now = new Date();
    const token = randomBytes(24).toString('hex');
    const hash = createHash('sha256').update(token).digest('hex');
    const reserved = await this.prisma.user.updateMany({
      where: {
        id: user.id,
        isActive: true,
        OR: [
          { passwordResetRequestedAt: null },
          { passwordResetRequestedAt: { lt: new Date(now.getTime() - 60_000) } },
        ],
      },
      data: {
        passwordResetHash: hash,
        passwordResetExpiresAt: new Date(now.getTime() + 15 * 60_000),
        passwordResetRequestedAt: now,
      },
    });
    if (!reserved.count) return genericMessage;
    try {
      const response = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        signal: AbortSignal.timeout(15_000),
        headers: {
          Authorization: `Bearer ${key}`,
          'Content-Type': 'application/json',
          'Idempotency-Key': `password-reset-${hash}`,
        },
        body: JSON.stringify({
          from,
          reply_to: this.config.get<string>('SUPPORT_EMAIL', 'vendeai.suport@gmail.com'),
          to: [user.email],
          subject: 'Recupere seu acesso ao VendAI',
          text: `Use este código no VendAI para escolher uma nova senha:\n\n${token}\n\nEle expira em 15 minutos e só pode ser usado uma vez. Se você não pediu a alteração, ignore este email. Não compartilhe o código.`,
        }),
      });
      if (!response.ok) throw new Error('Email delivery failed');
    } catch {
      this.logger.warn('Falha na entrega de email de recuperação; verifique o serviço de email.');
      await this.prisma.user.updateMany({
        where: { id: user.id, passwordResetHash: hash },
        data: { passwordResetHash: null, passwordResetExpiresAt: null },
      });
      // Do not expose account existence or provider responses to callers.
    }
    return genericMessage;
  }

  async reset(email: string, token: string, password: string) {
    const hash = createHash('sha256').update(token.trim()).digest('hex');
    const passwordHash = await bcrypt.hash(password, 10);
    const changed = await this.prisma.user.updateMany({
      where: {
        email: email.trim().toLowerCase(),
        isActive: true,
        passwordResetHash: hash,
        passwordResetExpiresAt: { gt: new Date() },
      },
      data: {
        passwordHash,
        refreshToken: null,
        passwordResetHash: null,
        passwordResetExpiresAt: null,
        sessionVersion: { increment: 1 },
      },
    });
    if (!changed.count)
      throw new BadRequestException('Código inválido ou expirado. Solicite um novo código.');
    return { message: 'Senha atualizada. Entre com sua nova senha.' };
  }
}
