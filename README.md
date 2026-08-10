# 🚀 VENDEAI — SaaS MVP

> **Assistente Inteligente de Gestão para Autônomos, MEIs e Pequenas Empresas**

O **VendeAI** é um ecossistema completo (Mobile + API Backend) construído para revolucionar a administração de pequenos negócios através de Inteligência Artificial Generativa. Elimina a necessidade de múltiplos aplicativos fragmentados ao reunir **Finanças, Gestão de Clientes, Orçamentos com PDF, Contratos Automáticos e Assistente IA (ChatGPT-like com AIProvider)** em um único lugar.

---

## 🏗️ Arquitetura do Projeto

O projeto adota os princípios da **Clean Architecture** e **SOLID**, garantindo desacoplamento total, facilidade de manutenção e escalabilidade sem necessidade de reescritas para os futuros módulos (CRM avançado, Estoque, Kanban, PIX, WhatsApp Business, Multi-empresa).

```
vendeai/
├── apps/
│   ├── backend/                  # NestJS API RESTful (TypeScript + Prisma ORM + Supabase)
│   │   ├── prisma/
│   │   │   ├── schema.prisma     # 12 Tabelas Normalizadas + Relacionamentos + Índices
│   │   │   └── seed.ts           # Seed automatizado para ambiente de desenvolvimento
│   │   ├── src/
│   │   │   ├── common/           # Interceptadores, Guards JWT, Throttler e Exception Filters
│   │   │   ├── modules/          # Auth, Users, Clients, Quotes, Contracts, Finance, AI, etc.
│   │   │   └── main.ts           # Bootstrap com Swagger OpenAPI, Helmet e CORS
│   │   └── test/                 # Testes unitários e e2e
│   │
│   └── mobile/                   # Aplicativo Mobile Cross-Platform (Flutter 3.x)
│       ├── lib/
│       │   ├── core/             # Storage, Network (Dio + JWT Interceptor), Tema Material 3
│       │   └── features/         # Auth, Dashboard, Clients, Quotes, Contracts, Finance, AI, etc.
│       └── test/                 # Testes de Widgets e Lógica de Negócio
├── docker-compose.yml            # Container para PostgreSQL Supabase local + NestJS
├── .env.example                  # Variáveis de ambiente configuráveis
└── .github/workflows/ci.yml      # CI/CD no GitHub Actions para validação e testes
```

---

## 🛠️ Tecnologias Utilizadas

### **Mobile (App iOS e Android)**
- **Framework:** Flutter (Última versão estável)
- **Gerenciamento de Estado:** Riverpod
- **Navegação & Roteamento:** Go Router
- **Modelagem de Dados:** Freezed & Json Serializable
- **Rede & Storage:** Dio (com Interceptor de JWT e renovação automática de Refresh Token), Flutter Secure Storage, Shared Preferences
- **Interface & UI:** Material 3, Dark & Light Mode, Google Fonts (*Plus Jakarta Sans*), FL Chart para gráficos financeiros, Glassmorphic UI & Micro-animações

### **Backend (API RESTful)**
- **Framework:** NestJS (TypeScript)
- **Autenticação & Segurança:** JWT, Refresh Token persistido no banco, Supabase Auth, Google OAuth, Helmet, CORS, Rate Limit (`@nestjs/throttler`)
- **ORM & Banco de Dados:** Prisma ORM integrado ao Supabase PostgreSQL
- **Documentação API:** Swagger OpenAPI 3.0 em `/api/docs`
- **Validação:** `class-validator` e `class-transformer` com ValidationPipe global
- **Geração de Documentos:** PDFKit para exportação profissional de Orçamentos e Contratos

### **Engine de Inteligência Artificial (`AIProvider`)**
- Arquitetura baseada em **Strategy / Provider Pattern** através da abstração `AIProvider`.
- Permite alternar de forma transparente entre **OpenAI (GPT-4o)**, **Google Gemini**, **Anthropic Claude** ou **MockAI local** (para dev offline e testes).
- Módulos de IA inclusos:
  1. Gerador de Orçamentos & Propostas Comerciais
  2. Gerador de Minutas de Contratos
  3. Assistente de Redação para WhatsApp & Cobrança Amigável
  4. Gerador de Anúncios (Instagram, Facebook Ads, Google Ads)
  5. Gerador de Descrições para E-commerce (**Mercado Livre, Shopee, Amazon**)
  6. Consultor de Dúvidas Financeiras e Comerciais

---

## 🗄️ Modelo de Banco de Dados (12 Tabelas Supabase)

1. `users` — Dados de autenticação, perfil e refresh tokens.
2. `profiles` — Dados completos da empresa, CPF/CNPJ, logotipo e endereço.
3. `clients` — Cadastro de clientes, empresas e observações.
4. `quotes` — Orçamentos com subtotal, desconto, total e código único.
5. `quote_items` — Itens individuais de cada orçamento.
6. `contracts` — Minutas e contratos comerciais com valor e vigência.
7. `categories` — Categorias financeiras personalizadas por usuário.
8. `finance_entries` — Lançamentos de Entradas (Receitas) e Saídas (Despesas).
9. `notifications` — Notificações do sistema para o usuário.
10. `files` — Arquivos e anexos enviados pelo usuário.
11. `settings` — Preferências de tema, idioma e provedor de IA.
12. `audit_logs` — Registros de auditoria e segurança.

---

## ⚡ Como Executar o Projeto Localmente

### Pré-requisitos
- Node.js v20+ e npm
- Docker e Docker Compose (opcional para banco local)
- Flutter SDK 3.22+

### 1. Clonar o Repositório e Configurar Envs
```bash
git clone https://github.com/usuario/vendeai.git
cd vendeai
cp .env.example .env
```

### 2. Iniciar o Backend (NestJS API)
```bash
cd apps/backend
npm install
npx prisma generate
npx prisma db push # ou npx prisma migrate dev
npm run prisma:seed # Popula categorias e usuário demo
npm run start:dev
```
A API estará acessível em: `http://localhost:3000/api/v1`  
Documentação Swagger ativa em: `http://localhost:3000/api/docs`

### 3. Executar o PostgreSQL via Docker Compose
Caso queira subir o PostgreSQL + Backend localmente via Docker:
```bash
docker-compose up -d --build
```

### 4. Executar o App Mobile (Flutter)
```bash
cd apps/mobile
flutter pub get
flutter run
```

---

## 🧪 Testes

### Backend (NestJS)
```bash
cd apps/backend
npm run test           # Testes unitários
npm run test:e2e       # Testes end-to-end
```

### Mobile (Flutter)
```bash
cd apps/mobile
flutter test           # Testes de widgets e validações
```

---

## 🌐 Instruções de Deploy

### **Backend (Railway, Render ou VPS)**
1. **Railway / Render:** Conecte o repositório GitHub e selecione o diretório `apps/backend`. O `Dockerfile` configurado na raiz da aplicação efetuará a compilação automática.
2. Defina as variáveis de ambiente (`DATABASE_URL`, `JWT_SECRET`, `OPENAI_API_KEY`).
3. O serviço executará a API com produção otimizada (`dist/main.js`).

### **Mobile (Google Play Store e Apple App Store)**
1. **Android:** Execute `flutter build appbundle --release` dentro de `apps/mobile/` e envie o arquivo `.aab` para o Google Play Console.
2. **iOS:** Execute `flutter build ipa --release` e envie via Xcode / Transporter para a App Store Connect.

---

## 📜 Licença

Desenvolvido para **VendeAI SaaS**. Todos os direitos reservados.
