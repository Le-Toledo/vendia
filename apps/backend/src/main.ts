import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';

import { AppModule } from './app.module';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);

  // Security Headers & CORS
  app.use(helmet());
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });

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
  await app.listen(port);

  logger.log(`🚀 Servidor VendeAI rodando em: http://localhost:${port}/${globalPrefix}`);
  logger.log(`📚 Documentação Swagger ativa em: http://localhost:${port}/api/docs`);
}

bootstrap();
