# Staging gratuito: Supabase + Render + Flutter

Este ambiente usa o Supabase **somente como PostgreSQL hospedado**. Autenticação, autorização, regras de negócio, Prisma e migrations continuam no backend NestJS. Não configure Supabase Auth, SDK, RLS, `anon key` ou `service_role key` no app.

## 1. Criar o PostgreSQL no Supabase

1. Crie um projeto no plano Free e escolha uma região adequada.
2. Guarde a senha do banco em um gerenciador de senhas.
3. No dashboard do projeto, abra **Connect** e copie a URI do **Session pooler** (Supavisor, porta `5432`). Ela tem formato semelhante a:

   ```text
   postgresql://postgres.PROJECT_REF:SENHA@aws-REGIAO.pooler.supabase.com:5432/postgres?sslmode=require
   ```

4. Use essa URI como `DATABASE_URL`. Não cole a senha em arquivos versionados, issues, logs ou no Flutter.

O backend do Render é um serviço persistente. No Supabase Free, o Session pooler é a opção compatível com redes IPv4 e pode ser usado pelo Prisma tanto no runtime quanto nas migrations. `DIRECT_URL` não é necessário nesta arquitetura. Se futuramente o host tiver IPv6 (ou o projeto contratar IPv4 dedicado), a conexão direta poderá ser avaliada separadamente.

### Aplicar migrations

Com a `DATABASE_URL` carregada apenas no shell local, execute antes do primeiro deploy e antes de cada versão que contenha migrations novas:

```bash
cd apps/backend
DATABASE_URL='COLE_A_URI_SESSION_POOLER_AQUI' \
npx prisma migrate deploy
```

Nunca use `prisma migrate dev` nem `prisma db push` em staging. Faça backup antes de migrations destrutivas e prefira migrations compatíveis e compensatórias.

## 2. Criar o backend no Render Free

No Render, escolha **New > Web Service**, conecte o repositório e configure:

- Runtime: `Docker`.
- Instance type: `Free`.
- Dockerfile path: `apps/backend/Dockerfile`.
- Docker build context: `apps/backend`.
- Health check path: `/api/v1/health/ready`.
- Branch: a branch escolhida para staging.

Não configure comando de start: o Render usará o `CMD` do Dockerfile. A API respeita `PORT`, escuta em `0.0.0.0`, roda como usuário não-root e a imagem final contém apenas dependências de produção.

### Variáveis do Render

Cadastre como secrets/variáveis no dashboard, sem aspas adicionais:

```text
NODE_ENV=staging
API_PREFIX=api/v1
DATABASE_URL=<URI SESSION POOLER DO SUPABASE COM sslmode=require>
JWT_SECRET=<SEGREDO ALEATORIO COM 32+ CARACTERES>
JWT_REFRESH_SECRET=<OUTRO SEGREDO ALEATORIO E DIFERENTE>
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
CORS_ORIGINS=https://seu-frontend-web.example
GOOGLE_AUTH_ENABLED=false
AI_PROVIDER=mock
THROTTLE_TTL=60000
THROTTLE_LIMIT=100
```

Não defina `PORT`; o Render fornece essa variável. Para um staging usado somente pelo app nativo, `CORS_ORIGINS` pode ficar vazio: clientes móveis normalmente não enviam `Origin`. Se houver Flutter Web ou painel web, liste apenas origens HTTPS exatas, separadas por vírgula, sem `*`.

Google permanece desligado até configurar `GOOGLE_CLIENT_ID` e mudar `GOOGLE_AUTH_ENABLED=true`. OpenAI é opcional no staging: mantenha `AI_PROVIDER=mock`; para ativar, use `AI_PROVIDER=openai`, `OPENAI_API_KEY` e opcionalmente `OPENAI_MODEL`.

O Render oferece pre-deploy command apenas em serviços pagos. Por isso, no Free, não execute migration no startup nem a inclua no build Docker: aplique-a explicitamente pelo passo anterior e só então faça o deploy. Em um futuro plano pago, configure `npx prisma migrate deploy` como pre-deploy command.

### Validar o deploy

Depois que o Render informar a URL pública, valide:

```bash
curl -fsS https://SEU-SERVICO.onrender.com/api/v1/health
curl -fsS https://SEU-SERVICO.onrender.com/api/v1/health/ready
```

O primeiro endpoint verifica o processo; o segundo também verifica PostgreSQL e é o health check apropriado do Render. No plano Free, a primeira chamada após inatividade pode demorar enquanto o serviço desperta.

## 3. Executar o Flutter contra staging

Não grave a URL do Render no código. Para testar no iPhone conectado:

```bash
cd apps/mobile
flutter devices
flutter run -d <ID_DO_IPHONE> \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://SEU-SERVICO.onrender.com/api/v1
```

Para gerar um IPA de staging:

```bash
flutter build ipa --release \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://SEU-SERVICO.onrender.com/api/v1
```

Ambientes suportados:

- `development`: permite fallback local para `http://localhost:3000/api/v1` quando a URL não é informada.
- `staging`: exige `API_BASE_URL` absoluta em HTTPS.
- `production`: exige `API_BASE_URL` absoluta em HTTPS.
- qualquer build release exige `API_BASE_URL`, mesmo se `APP_ENV` for omitida.

## Checklist antes de compartilhar o staging

- Migration aplicada com sucesso no projeto correto do Supabase.
- Nenhuma credencial presente no Git, Flutter, imagem Docker ou logs.
- Segredos JWT distintos dos ambientes local e produção.
- `CORS_ORIGINS` contém somente origens web necessárias.
- `/health` e `/health/ready` respondem sem expor detalhes sensíveis.
- Cadastro, login, refresh, isolamento entre dois usuários e fluxos principais testados.
- Limites gratuitos, suspensão por inatividade e ausência de SLA aceitos para staging, não para produção.
