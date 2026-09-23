# VendeAI

Aplicação SaaS para gestão de clientes, orçamentos, contratos e finanças, com app Flutter e API NestJS. O produto possui autenticação JWT, isolamento de dados por usuário, geração de PDF de orçamentos e integração opcional com Google Sign-In e OpenAI.

## Arquitetura real

- `apps/backend`: NestJS 11, Prisma 5, PostgreSQL, JWT, Google Auth Library, PDFKit e OpenAI via HTTP.
- `apps/mobile`: Flutter 3.44, Riverpod, GoRouter, Dio e Flutter Secure Storage.
- `docker-compose.yml`: PostgreSQL e backend para desenvolvimento.
- `.github/workflows/ci.yml`: lint, build, migrations, testes unitários/e2e e testes Flutter.

O Flutter consome a API para autenticação, perfil, dashboard, clientes, orçamentos, contratos, finanças e IA. Algumas experiências ainda são deliberadamente simples: contratos não possuem formulário dedicado, recuperação de senha ainda não possui serviço de e-mail e o download/compartilhamento de PDF precisa de integração nativa no app.

## Pré-requisitos

- Node.js 22+
- Flutter 3.44.8
- PostgreSQL 15+
- Docker/Compose opcional

## Configuração do backend

```bash
cp .env.example .env
cd apps/backend
npm ci
npx prisma generate
npx prisma migrate deploy
npm run start:dev
```

Variáveis obrigatórias:

- `DATABASE_URL`: conexão PostgreSQL.
- `JWT_SECRET`: segredo aleatório com pelo menos 32 caracteres.
- `JWT_REFRESH_SECRET`: segredo diferente do anterior, também com pelo menos 32 caracteres.
- `CORS_ORIGINS`: origens web permitidas separadas por vírgula. Clientes mobile sem header `Origin` são aceitos.

Integrações opcionais:

- `GOOGLE_AUTH_ENABLED=true` exige `GOOGLE_CLIENT_ID`. Sem ambos, o endpoint retorna indisponível e nunca usa fallback.
- `AI_PROVIDER` aceita `openai`, `gemini` e `groq`; cada opção exige a chave correspondente no servidor (`OPENAI_API_KEY`, `GEMINI_API_KEY` ou `GROQ_API_KEY`). `OPENAI_MODEL`, `GEMINI_MODEL` e `GROQ_MODEL` selecionam o modelo. O Docker Compose repassa essas configurações. `mock` é permitido apenas fora de produção; nunca inclua chaves de IA nos defines do aplicativo.

A configuração aceita `NODE_ENV=development|test|staging|production` e falha na inicialização quando valores obrigatórios são inválidos. Nunca reutilize valores entre ambientes.

O staging gratuito (Supabase PostgreSQL + Render Docker) está detalhado em [`DEPLOY.md`](DEPLOY.md). O Supabase não substitui a autenticação JWT do NestJS e o app não recebe chaves do banco.

## Banco e migrations

O schema usa `Decimal(14,2)` para dinheiro e códigos de orçamento aleatórios resistentes a colisão com unicidade por usuário.

```bash
cd apps/backend
npx prisma migrate deploy   # staging/produção
npx prisma migrate dev      # somente desenvolvimento de schema
```

A migration inicial cria o banco completo. Bancos existentes criados anteriormente por `db push` devem ser primeiro comparados e baselined conforme a documentação do Prisma; faça backup antes. Rollback é feito restaurando o backup ou por uma migration compensatória testada — não apague migrations já aplicadas.

## Flutter e ambientes

A URL é fornecida em build time, não incorporada à configuração de produção:

```bash
cd apps/mobile
flutter pub get
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

- iOS Simulator: normalmente `http://localhost:3000/api/v1`.
- Android Emulator: normalmente `http://10.0.2.2:3000/api/v1`.
- Dispositivo físico: use o IP HTTPS acessível da máquina de desenvolvimento.
- Staging/produção: use obrigatoriamente uma URL HTTPS pública.

Para Google Sign-In, acrescente `--dart-define=GOOGLE_SERVER_CLIENT_ID=<oauth-web-client-id>` e configure os arquivos/plataformas Android e iOS no Google Cloud/Firebase conforme seus bundle IDs. O mesmo client ID deve ser aceito pelo backend.

Exemplos de release:

```bash
flutter build appbundle --release --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api.example.com/api/v1
flutter build ipa --release --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

`API_BASE_URL` é obrigatória em staging e em qualquer build release, deve ser HTTPS e não possui fallback silencioso para localhost nesses ambientes. Builds release exigem HTTPS mesmo quando `APP_ENV` é omitido; para produção, defina explicitamente `APP_ENV=production` e a URL real da API. URLs com credenciais, query string ou fragmento são rejeitadas.

## Qualidade e testes

Backend:

```bash
cd apps/backend
npm run format:check
npm run lint
npm run build
npm test -- --runInBand
npm run test:e2e -- --runInBand
npm audit --omit=dev
```

Os testes e2e exigem PostgreSQL vazio, migrations aplicadas e variáveis JWT de teste. Nunca aponte testes para produção.

Flutter:

```bash
cd apps/mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Docker

Defina os secrets no ambiente e execute:

```bash
docker compose up --build
```

A imagem usa build multi-stage, instala somente dependências de produção na etapa final, executa como usuário não-root e possui health check. Aplique `npx prisma migrate deploy` como etapa explícita do deploy antes de trocar o tráfego.

## Operação e observabilidade

- `GET /api/v1/health`: liveness.
- `GET /api/v1/health/ready`: readiness com PostgreSQL.
- Respostas incluem `X-Request-Id`; erros incluem `requestId`.
- Logs não devem conter tokens, senhas ou secrets.
- Integre uma plataforma de erros/métricas no ambiente de hospedagem; isso depende de conta e credencial externas.

## LGPD, backup e retenção

- `GET /api/v1/users/export`: exporta dados do titular autenticado.
- `DELETE /api/v1/users/me` com `{ "confirmation": "EXCLUIR" }`: exclui a conta e relações em cascata.
- A política de retenção proposta é manter dados enquanto a conta estiver ativa e removê-los na exclusão, respeitando backups e obrigações legais. Prazos definitivos, política de privacidade e termos exigem validação jurídica.
- Habilite backups PostgreSQL criptografados, teste restauração periodicamente e defina RPO/RTO com o proprietário. Antes de migrations monetárias ou destrutivas, faça snapshot verificável.

## Checklist de produção

- Configurar DNS, HTTPS, banco gerenciado e secrets exclusivos.
- Configurar Google OAuth para os bundle IDs e client ID reais.
- Configurar OpenAI, limites de gasto e monitoramento.
- Aplicar migrations e validar readiness antes de liberar tráfego.
- Configurar backups/restauração e monitoramento de erro/latência.
- Revisar LGPD, termos, privacidade e retenção com jurídico.
- Assinar e publicar Android/iOS nas contas oficiais.
- Implementar recuperação de senha/e-mail transacional e formulário dedicado de contratos antes do lançamento amplo.

## Deploy e rollback

Construa um artefato imutável, execute migrations compatíveis retroativamente, valide `/health/ready` e faça troca gradual de tráfego. Para rollback de aplicação, reimplante a imagem anterior. Para banco, prefira migrations compatíveis/compensatórias; restaure backup apenas em incidente confirmado e com procedimento testado.
