import { ConfigService } from '@nestjs/config';

export const PRIVACY_VERSION = '2026-09-22';
export function aiProviderInfo(config: ConfigService) {
  const id = config.get<string>('AI_PROVIDER', 'mock');
  const names: Record<string, string> = {
    groq: 'Groq',
    openai: 'OpenAI',
    gemini: 'Google Gemini',
    mock: 'Simulação local (sem envio a provedor de IA)',
  };
  return { id, name: names[id] ?? 'Provedor indisponível' };
}
export function privacyInfo(config: ConfigService) {
  const provider = aiProviderInfo(config);
  const controller = config.get<string>('PRIVACY_CONTROLLER_NAME', 'VendeAI');
  const contact = config.get<string>('SUPPORT_EMAIL', 'vendeai.suport@gmail.com');
  return {
    version: PRIVACY_VERSION,
    title: 'Privacidade no VendeAI',
    controller,
    contact,
    sections: [
      {
        title: 'Responsável e contato',
        text: contact
          ? `${controller} é responsável pelo VendeAI. Contato para suporte e solicitações sobre dados: ${contact}.`
          : 'O contato do responsável precisa ser configurado antes da distribuição pública.',
      },
      {
        title: 'Dados utilizados',
        text: 'Usamos os dados de cadastro e perfil, clientes, orçamentos, contratos e lançamentos que você informa para autenticar sua conta e oferecer as funções de gestão. Senhas são armazenadas como hashes; tokens mantêm sua sessão. Não coloque dados de terceiros sem autorização.',
      },
      {
        title: 'Inteligência artificial',
        text: `Com sua autorização, os textos enviados ao chat e ao gerador de marketing são processados pelo provedor ${provider.name}. O provedor recebe o texto necessário à solicitação e pode processá-lo fora do Brasil, conforme seus termos. Evite senhas, documentos, informações sensíveis ou dados pessoais desnecessários. Você pode recusar ou revogar a autorização sem perder as funções de gestão. Revogar impede novos envios; não desfaz solicitações já processadas.`,
      },
      {
        title: 'Login e infraestrutura',
        text: 'Ao escolher login social, o serviço de autenticação compartilha a identificação e os dados necessários para criar ou acessar sua conta. Os serviços de hospedagem, banco de dados e entrega de email processam dados necessários à operação e à recuperação de acesso. O app não inclui publicidade comportamental nem rastreamento publicitário.',
      },
      {
        title: 'Seus controles',
        text: 'Em Configurações, você pode exportar seus dados, revogar o envio à IA e solicitar a exclusão da conta. A exclusão remove os registros da conta no banco operacional. Registros sujeitos a obrigação legal e cópias de segurança podem exigir tratamento separado; consulte o responsável sobre prazos e pedidos específicos.',
      },
      {
        title: 'Segurança e atualização',
        text: 'A comunicação de produção usa HTTPS. Proteja seu dispositivo e suas credenciais. Os dados permanecem necessários enquanto a conta estiver ativa; solicitações de acesso, correção e esclarecimentos podem ser encaminhadas ao contato acima. Mudanças relevantes nesta política exigem uma nova versão.',
      },
    ],
  };
}
