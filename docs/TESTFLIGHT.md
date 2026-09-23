# Preparar VendeAI para TestFlight

O código foi preparado para login por senha/Google/Apple, recuperação por email, consentimento de IA e privacidade. A API e o aplicativo precisam ser publicados juntos, com as migrations aplicadas. Não substitua uma API antiga sem migrar o banco.

## 1. Serviços necessários

- Um servidor com Docker e um domínio apontando para ele, acessível nas portas 80/443.
- Um serviço de email Resend com remetente/domínio verificado. O contato público `vendeai.suport@gmail.com` é usado como suporte e reply-to; não é automaticamente um remetente autorizado no Resend.
- Credenciais de um provedor de IA real, restritas ao servidor.
- Clientes OAuth Google: cliente iOS do Bundle ID correto e cliente servidor/Web. O backend deve usar como GOOGLE_CLIENT_ID o mesmo GOOGLE_SERVER_CLIENT_ID do app.
- Para Apple: ativar Sign in with Apple no App ID, atualizar o provisioning profile, criar a chave do serviço e configurar APPLE_CLIENT_ID (Bundle ID), APPLE_TEAM_ID, APPLE_KEY_ID, APPLE_PRIVATE_KEY e uma chave aleatória de 32 bytes em hexadecimal para APPLE_TOKEN_ENCRYPTION_KEY. Não troque a chave de criptografia enquanto existirem tokens Apple armazenados, sem antes planejar a migração desses dados. As credenciais privadas nunca entram no Flutter.

O Bundle ID atual é `com.example.vendeaiMobile`; use o mesmo em todos os serviços enquanto não optar por mudar. A conta Apple, certificados e upload ficam sob responsabilidade do titular.

## 2. Publicar o servidor

Use `docker-compose.production.yml` e `deploy/Caddyfile`. Essa configuração:

- inicia PostgreSQL sem expor sua porta ao público;
- executa migrations antes de iniciar o backend;
- exige secrets reais e distintos, email configurado e IA não simulada;
- oferece HTTPS automático pelo Caddy após o domínio apontar para o servidor.

Crie `.env.production` no servidor com os campos documentados em `.env.example`, além de `APP_DOMAIN` e `DB_PASSWORD`. Use uma senha aleatória hexadecimal para o banco (evita ambiguidade de caracteres na URL). O arquivo deve ficar fora do Git e restrito ao operador. Configure NODE_ENV=production, GOOGLE_AUTH_ENABLED=true e APPLE_AUTH_ENABLED=true para habilitar todos os logins oferecidos no iOS.

Execute no servidor:

```sh
docker compose --env-file .env.production -f docker-compose.production.yml up -d --build
```

A implantação não foi executada nesta tarefa: nenhuma conta de hospedagem, domínio ou credencial de envio foi fornecida. O Docker local estava sem daemon ativo; o YAML foi validado, mas o build da imagem não foi executado.

Confirme `/api/v1/health/ready`, `/api/v1/app/config` e `/api/v1/app/privacy`. A política pública estará no próprio backend, e o app exibe o mesmo texto. Revise os dados do responsável e os detalhes operacionais de hospedagem/backup antes de distribuir publicamente. O manifesto iOS não substitui as respostas de App Privacy no App Store Connect.

Faça backup antes de migrar um banco existente. Migrations novas são aditivas, mas a exclusão de conta remove dados de forma permanente quando o usuário confirma.

## 3. Gerar o archive

Crie um JSON local com SOMENTE os quatro campos públicos abaixo, preenchidos com valores reais:

- APP_ENV: production
- API_BASE_URL: URL HTTPS real, terminando em /api/v1
- GOOGLE_IOS_CLIENT_ID: cliente OAuth iOS
- GOOGLE_SERVER_CLIENT_ID: cliente OAuth servidor/Web

Não inclua chaves de IA, senhas, certificados ou chaves Apple nesse JSON.

```sh
python3 scripts/prepare-testflight.py /caminho/config-publica.json --build-number 2 --check-only
python3 scripts/prepare-testflight.py /caminho/config-publica.json --build-number 2
```

Escolha um número de build ainda não usado no App Store Connect. O script valida a API/banco, presença de configuração de email, logins habilitados e política. Não envia emails nem garante que credenciais de provedores estejam válidas: faça um teste real de cada fluxo antes de distribuir.

O script configura GIDClientID/GIDServerClientID e o esquema reverso nos plists, executa análise/testes e gera o archive/IPA. Ele NÃO faz upload nem acessa sua conta Apple. `--unsigned` permite gerar somente um archive sem assinatura; ele não é uma IPA distribuível.

## 4. Conferência em aparelho e TestFlight

1. Instalação limpa: campos de login vazios e mensagens de erro visíveis.
2. Cadastro, login por senha, Google e Apple, inclusive cancelar o login social.
3. Recuperação com email realmente entregue: código expira, não pode ser reutilizado, senha antiga/sessões antigas deixam de funcionar.
4. IA não envia texto antes de autorizar; recusa preserva o rascunho; revogação impede novos envios.
5. Privacidade acessível pelo login e Configurações; suporte correto.
6. Exportação e exclusão com clientes, orçamentos e contratos de teste. Apple é revogada antes de excluir uma conta vinculada.
7. Compartilhamento de PDF/dados em iPhone e iPad, offline/reconexão e expiração de sessão.
8. Archive com assinatura do titular, manifesto de privacidade incluído, ícone VendeAI e sem permissão de rede local de desenvolvimento no Release.

TestFlight interno e externo têm exigências diferentes; testes externos podem passar por Beta App Review. A validação local não é aprovação da Apple.

Fontes: [TestFlight](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/), [Sign in with Apple](https://pub.dev/packages/sign_in_with_apple/versions/7.0.1), [Resend](https://resend.com/docs/api-reference/emails/send-email).
