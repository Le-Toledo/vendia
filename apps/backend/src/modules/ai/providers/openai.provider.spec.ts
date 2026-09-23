import { BadGatewayException, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { OpenAIProvider } from './openai.provider';

describe('OpenAIProvider', () => {
  const config = (key?: string) =>
    ({
      get: (name: string, fallback?: string) => (name === 'OPENAI_API_KEY' ? key : fallback),
    }) as unknown as ConfigService;
  afterEach(() => jest.restoreAllMocks());

  it('fails explicitly when no key is configured', async () => {
    await expect(new OpenAIProvider(config()).generateText('hello')).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });

  it('rejects malformed successful responses', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({ choices: [] }),
    } as Response);
    await expect(new OpenAIProvider(config('key')).generateText('hello')).rejects.toBeInstanceOf(
      BadGatewayException,
    );
  });

  it('returns validated content', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({ choices: [{ message: { content: 'Resposta real' } }] }),
    } as Response);
    await expect(new OpenAIProvider(config('key')).generateText('hello')).resolves.toEqual({
      content: 'Resposta real',
      actionType: 'none',
    });
  });
});
