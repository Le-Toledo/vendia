import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { json, urlencoded } from 'express';

import { AppModule } from './app.module';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);

  if (process.env.TRUST_PROXY === 'true') app.getHttpAdapter().getInstance().set('trust proxy', 1);

  // Security Headers & CORS
  app.use(helmet());
  const allowedOrigins = (process.env.CORS_ORIGINS || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
  app.enableCors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) return callback(null, true);
      return callback(new Error('Origin not allowed by CORS'), false);
    },
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });
  app.use(json({ limit: '1mb' }));
  app.use(urlencoded({ limit: '1mb', extended: true }));

  // Global Prefix & Validation Pipe
  const globalPrefix = process.env.API_PREFIX || 'api/v1';
  app.setGlobalPrefix(globalPrefix);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Swagger Documentation Setup
  const config = new DocumentBuilder()
    .setTitle('VendeAI SaaS API')
    .setDescription(
      'API RESTful do VendeAI - Assistente de gestão inteligente com IA para autônomos, MEIs e pequenas empresas.',
    )
    .setVersion('1.0.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0');

  logger.log(`Servidor VendeAI ouvindo na porta ${port} (prefixo /${globalPrefix})`);
  logger.log('Documentação Swagger disponível em /api/docs');
}

void bootstrap();
