import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { PrismaService } from '../src/common/prisma/prisma.service';
import { AppModule } from '../src/app.module';

describe('VendeAI API (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const module = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = module.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
    );
    await app.init();
  });

  afterAll(() => app.close());

  it('reports liveness', () =>
    request(app.getHttpServer())
      .get('/api/v1/health')
      .expect(200)
      .expect(({ body }) => expect(body.data.status).toBe('ok')));

  it('registers, authenticates and isolates client collections', async () => {
    const suffix = Date.now();
    const first = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({
        fullName: 'User One',
        email: `one-${suffix}@example.com`,
        password: 'StrongPassword1!',
      })
      .expect(201);
    const second = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({
        fullName: 'User Two',
        email: `two-${suffix}@example.com`,
        password: 'StrongPassword1!',
      })
      .expect(201);
    const firstToken = first.body.data.tokens.accessToken;
    const secondToken = second.body.data.tokens.accessToken;
    const client = await request(app.getHttpServer())
      .post('/api/v1/clients')
      .set('Authorization', `Bearer ${firstToken}`)
      .send({ name: 'Private Client' })
      .expect(201);
    await request(app.getHttpServer())
      .get(`/api/v1/clients/${client.body.data.id}`)
      .set('Authorization', `Bearer ${secondToken}`)
      .expect(404);
    const list = await request(app.getHttpServer())
      .get('/api/v1/clients')
      .set('Authorization', `Bearer ${secondToken}`)
      .expect(200);
    expect(list.body.data.items).toHaveLength(0);
  });

  it('logs in, rotates refresh tokens and revokes them on logout', async () => {
    const email = `session-${Date.now()}@example.com`;
    const password = 'StrongPassword1!';
    await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ fullName: 'Session User', email, password })
      .expect(201);
    const login = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password })
      .expect(200);
    const refreshed = await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: login.body.data.tokens.refreshToken })
      .expect(200);
    await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: login.body.data.tokens.refreshToken })
      .expect(401);
    await request(app.getHttpServer())
      .post('/api/v1/auth/logout')
      .set('Authorization', `Bearer ${refreshed.body.data.accessToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: refreshed.body.data.refreshToken })
      .expect(401);
  });
  it('publishes privacy, requires AI consent, allows revocation and deletes related account data', async () => {
    const config = await request(app.getHttpServer()).get('/api/v1/app/config').expect(200);
    expect(config.body.data.privacy.contact).toBe('vendeai.suport@gmail.com');
    const policy = await request(app.getHttpServer()).get('/api/v1/app/privacy').expect(200);
    expect(policy.text).toContain('Privacidade');
    const registered = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({
        fullName: 'Consent User',
        email: `consent-${Date.now()}@example.com`,
        password: 'StrongPassword1!',
      })
      .expect(201);
    const token = registered.body.data.tokens.accessToken;
    const uid = registered.body.data.user.id;
    const auth = `Bearer ${token}`;
    await request(app.getHttpServer())
      .post('/api/v1/ai/chat')
      .set('Authorization', auth)
      .send({ message: 'Olá' })
      .expect(403);
    await request(app.getHttpServer())
      .post('/api/v1/ai/generate-copy')
      .set('Authorization', auth)
      .send({ targetChannel: 'Instagram', productOrService: 'Teste' })
      .expect(403);
    await request(app.getHttpServer())
      .put('/api/v1/users/ai-consent')
      .set('Authorization', auth)
      .send({ approved: true, version: 'outdated', provider: 'mock' })
      .expect(400);
    await request(app.getHttpServer())
      .put('/api/v1/users/ai-consent')
      .set('Authorization', auth)
      .send({
        approved: true,
        version: config.body.data.ai.consentVersion,
        provider: config.body.data.ai.id,
      })
      .expect(200);
    await request(app.getHttpServer())
      .post('/api/v1/ai/chat')
      .set('Authorization', auth)
      .send({ message: 'Olá' })
      .expect(201);
    await request(app.getHttpServer())
      .put('/api/v1/users/ai-consent')
      .set('Authorization', auth)
      .send({ approved: false })
      .expect(200);
    await request(app.getHttpServer())
      .post('/api/v1/ai/chat')
      .set('Authorization', auth)
      .send({ message: 'Olá' })
      .expect(403);
    const db = app.get(PrismaService);
    const client = await db.client.create({ data: { userId: uid, name: 'Cliente de teste' } });
    await db.quote.create({
      data: {
        userId: uid,
        clientId: client.id,
        codeNumber: 'Q-TEST',
        items: { create: { description: 'Teste', quantity: 1, unitPrice: 1, totalPrice: 1 } },
      },
    });
    await db.contract.create({
      data: { userId: uid, clientId: client.id, title: 'Teste', content: 'Teste' },
    });
    const exported = await request(app.getHttpServer())
      .get('/api/v1/users/export')
      .set('Authorization', auth)
      .expect(200);
    expect(exported.body.data.data.quotes).toHaveLength(1);
    await request(app.getHttpServer())
      .delete('/api/v1/users/me')
      .set('Authorization', auth)
      .send({ confirmation: 'EXCLUIR' })
      .expect(200);
    expect(await db.user.findUnique({ where: { id: uid } })).toBeNull();
    expect(await db.client.count({ where: { userId: uid } })).toBe(0);
    await request(app.getHttpServer())
      .get('/api/v1/users/me')
      .set('Authorization', auth)
      .expect(401);
  });

  it('resets password once and invalidates old access and refresh tokens', async () => {
    const email = `reset-${Date.now()}@example.com`;
    const registered = await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ fullName: 'Reset User', email, password: 'StrongPassword1!' })
      .expect(201);
    const send = jest.spyOn(global, 'fetch').mockResolvedValue({ ok: true } as Response);
    try {
      await request(app.getHttpServer())
        .post('/api/v1/auth/forgot-password')
        .send({ email })
        .expect(200);
      const payload = JSON.parse(send.mock.calls[0][1]!.body as string);
      const token = payload.text.match(/[a-f0-9]{48}/)[0];
      const db = app.get(PrismaService);
      const stored = await db.user.findUniqueOrThrow({ where: { email } });
      expect(stored.passwordResetHash).not.toBe(token);
      const data = { email, token, password: 'NewStrongPassword2!' };
      await request(app.getHttpServer()).post('/api/v1/auth/reset-password').send(data).expect(200);
      await request(app.getHttpServer()).post('/api/v1/auth/reset-password').send(data).expect(400);
      await request(app.getHttpServer())
        .get('/api/v1/users/me')
        .set('Authorization', `Bearer ${registered.body.data.tokens.accessToken}`)
        .expect(401);
      await request(app.getHttpServer())
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: registered.body.data.tokens.refreshToken })
        .expect(401);
      await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ email, password: 'StrongPassword1!' })
        .expect(401);
      await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ email, password: data.password })
        .expect(200);
    } finally {
      send.mockRestore();
    }
  });
});
