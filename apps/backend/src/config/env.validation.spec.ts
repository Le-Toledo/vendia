import { validateEnvironment } from './env.validation';

describe('environment validation', () => {
  const base = {
    DATABASE_URL: 'postgresql://user:pass@localhost:5432/db',
    JWT_SECRET: 'a'.repeat(32),
    JWT_REFRESH_SECRET: 'b'.repeat(32),
  };
  it('accepts a safe minimal development environment', () =>
    expect(validateEnvironment(base).DATABASE_URL).toBe(base.DATABASE_URL));
  it('rejects equal JWT secrets', () =>
    expect(() => validateEnvironment({ ...base, JWT_REFRESH_SECRET: base.JWT_SECRET })).toThrow(
      'must be different',
    ));
  it('requires Google client id when enabled', () =>
    expect(() => validateEnvironment({ ...base, GOOGLE_AUTH_ENABLED: 'true' })).toThrow(
      'GOOGLE_CLIENT_ID',
    ));
  it('requires OpenAI key when selected', () =>
    expect(() => validateEnvironment({ ...base, AI_PROVIDER: 'openai' })).toThrow(
      'OPENAI_API_KEY',
    ));
});
