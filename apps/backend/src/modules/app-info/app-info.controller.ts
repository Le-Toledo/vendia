import { Controller, Get, Res } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Response } from 'express';
import { aiProviderInfo, privacyInfo, PRIVACY_VERSION } from './privacy';

@Controller('app')
export class AppInfoController {
  constructor(private readonly config: ConfigService) {}
  @Get('config')
  getConfig() {
    return {
      privacy: privacyInfo(this.config),
      ai: { ...aiProviderInfo(this.config), consentVersion: PRIVACY_VERSION },
      appleAuthEnabled: Boolean(this.config.get<boolean>('APPLE_AUTH_ENABLED')),
      googleAuthEnabled: Boolean(this.config.get<boolean>('GOOGLE_AUTH_ENABLED')),
      passwordResetEnabled: Boolean(
        this.config.get<string>('RESEND_API_KEY') && this.config.get<string>('MAIL_FROM'),
      ),
    };
  }
  @Get('privacy')
  privacy(@Res() response: Response) {
    const policy = privacyInfo(this.config);
    const escape = (value: string) =>
      value.replace(
        /[&<>"']/g,
        (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]!,
      );
    response
      .type('html')
      .send(
        `<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Privacidade — VendeAI</title></head><body><main><h1>${escape(policy.title)}</h1><p>Versão ${policy.version}</p>${policy.sections.map((section) => `<section><h2>${escape(section.title)}</h2><p>${escape(section.text)}</p></section>`).join('')}</main></body></html>`,
      );
  }
}
