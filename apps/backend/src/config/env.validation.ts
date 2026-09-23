import { z } from 'zod';

const booleanString = z
  .enum(['true', 'false'])
  .default('false')
  .transform((value) => value === 'true');

const envSchema = z
  .object({
    NODE_ENV: z.enum(['development', 'test', 'staging', 'production']).default('development'),
    PORT: z.coerce.number().int().min(1).max(65535).default(3000),
    API_PREFIX: z.string().min(1).default('api/v1'),
    DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
    JWT_SECRET: z.string().min(32, 'JWT_SECRET must contain at least 32 characters'),
    JWT_REFRESH_SECRET: z
      .string()
      .min(32, 'JWT_REFRESH_SECRET must contain at least 32 characters'),
    JWT_EXPIRES_IN: z.string().default('15m'),
    JWT_REFRESH_EXPIRES_IN: z.string().default('7d'),
    CORS_ORIGINS: z.string().default('http://localhost:3000,http://localhost:8080'),
    GOOGLE_AUTH_ENABLED: booleanString,
    TRUST_PROXY: booleanString,
    APPLE_AUTH_ENABLED: booleanString,
    APPLE_CLIENT_ID: z.string().optional(),
    APPLE_KEY_ID: z.string().optional(),
    APPLE_TEAM_ID: z.string().optional(),
    APPLE_PRIVATE_KEY: z.string().optional(),
    APPLE_TOKEN_ENCRYPTION_KEY: z.string().optional(),
    GOOGLE_CLIENT_ID: z.string().optional(),
    AI_PROVIDER: z.enum(['mock', 'openai', 'gemini', 'groq']).default('mock'),
    OPENAI_API_KEY: z.string().optional(),
    OPENAI_MODEL: z.string().default('gpt-4o-mini'),
    GEMINI_API_KEY: z.string().optional(),
    GEMINI_MODEL: z.string().default('gemini-2.5-flash'),
    GROQ_API_KEY: z.string().optional(),
    GROQ_MODEL: z.string().default('llama-3.3-70b-versatile'),
    PRIVACY_CONTROLLER_NAME: z.string().default('VendAI'),
    SUPPORT_EMAIL: z.string().email().default('vendeai.suport@gmail.com'),
    RESEND_API_KEY: z.string().optional(),
    MAIL_FROM: z.string().optional(),
    THROTTLE_TTL: z.coerce.number().int().positive().default(60000),
    THROTTLE_LIMIT: z.coerce.number().int().positive().default(100),
  })
  .superRefine((env, ctx) => {
    if (env.JWT_SECRET === env.JWT_REFRESH_SECRET) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['JWT_REFRESH_SECRET'],
        message: 'JWT secrets must be different',
      });
    }
    if (env.GOOGLE_AUTH_ENABLED && !env.GOOGLE_CLIENT_ID) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['GOOGLE_CLIENT_ID'],
        message: 'GOOGLE_CLIENT_ID is required when Google auth is enabled',
      });
    }
    if (env.AI_PROVIDER === 'openai' && !env.OPENAI_API_KEY) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['OPENAI_API_KEY'],
        message: 'OPENAI_API_KEY is required when AI_PROVIDER=openai',
      });
    }
    if (env.AI_PROVIDER === 'gemini' && !env.GEMINI_API_KEY) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['GEMINI_API_KEY'],
        message: 'GEMINI_API_KEY is required when AI_PROVIDER=gemini',
      });
    }
    if (env.AI_PROVIDER === 'groq' && !env.GROQ_API_KEY) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['GROQ_API_KEY'],
        message: 'GROQ_API_KEY is required when AI_PROVIDER=groq',
      });
    }

    if (env.APPLE_AUTH_ENABLED) {
      for (const key of [
        'APPLE_CLIENT_ID',
        'APPLE_KEY_ID',
        'APPLE_TEAM_ID',
        'APPLE_PRIVATE_KEY',
      ] as const) {
        if (!env[key]?.trim())
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            path: [key],
            message: `${key} is required for Apple authentication`,
          });
      }
      if (!/^[a-fA-F0-9]{64}$/.test(env.APPLE_TOKEN_ENCRYPTION_KEY ?? ''))
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['APPLE_TOKEN_ENCRYPTION_KEY'],
          message: 'Configure a 32-byte hexadecimal key for Apple tokens',
        });
    }
    if (env.NODE_ENV === 'production') {
      for (const key of [
        'PRIVACY_CONTROLLER_NAME',
        'SUPPORT_EMAIL',
        'RESEND_API_KEY',
        'MAIL_FROM',
      ] as const) {
        if (!env[key]?.trim())
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            path: [key],
            message: `${key} is required in production`,
          });
      }
    }
    if (env.NODE_ENV === 'production' && env.AI_PROVIDER === 'mock') {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['AI_PROVIDER'],
        message: 'AI_PROVIDER=mock is not allowed in production',
      });
    }
  });

export type Environment = z.infer<typeof envSchema>;

export function validateEnvironment(config: Record<string, unknown>): Environment {
  const result = envSchema.safeParse(config);
  if (!result.success) {
    const details = result.error.issues
      .map((issue) => `${issue.path.join('.')}: ${issue.message}`)
      .join('; ');
    throw new Error(`Invalid environment configuration: ${details}`);
  }
  return result.data;
}
