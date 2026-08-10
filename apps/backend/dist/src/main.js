"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const helmet_1 = require("helmet");
const app_module_1 = require("./app.module");
async function bootstrap() {
    const logger = new common_1.Logger('Bootstrap');
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.use((0, helmet_1.default)());
    app.enableCors({
        origin: '*',
        methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
        credentials: true,
    });
    const globalPrefix = process.env.API_PREFIX || 'api/v1';
    app.setGlobalPrefix(globalPrefix);
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
        transformOptions: {
            enableImplicitConversion: true,
        },
    }));
    const config = new swagger_1.DocumentBuilder()
        .setTitle('VendeAI SaaS API')
        .setDescription('API RESTful do VendeAI - Assistente de gestão inteligente com IA para autônomos, MEIs e pequenas empresas.')
        .setVersion('1.0.0')
        .addBearerAuth()
        .build();
    const document = swagger_1.SwaggerModule.createDocument(app, config);
    swagger_1.SwaggerModule.setup('api/docs', app, document);
    const port = process.env.PORT || 3000;
    await app.listen(port);
    logger.log(`🚀 Servidor VendeAI rodando em: http://localhost:${port}/${globalPrefix}`);
    logger.log(`📚 Documentação Swagger ativa em: http://localhost:${port}/api/docs`);
}
bootstrap();
//# sourceMappingURL=main.js.map