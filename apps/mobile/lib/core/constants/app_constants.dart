class AppConstants {
  static const String appName = 'VendAI';
  static const String appTagline =
      'Seu Assistente de Negócios com Inteligência Artificial';
  static const String appEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const String _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const bool _isRelease = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    return resolveApiBaseUrl(
      environment: appEnvironment,
      configuredUrl: _configuredApiBaseUrl,
      isRelease: _isRelease,
    );
  }

  static String resolveApiBaseUrl({
    required String environment,
    required String configuredUrl,
    required bool isRelease,
  }) {
    const validEnvironments = {'development', 'staging', 'production'};
    if (!validEnvironments.contains(environment)) {
      throw StateError('APP_ENV deve ser development, staging ou production.');
    }

    configuredUrl = configuredUrl.trim();
    if (configuredUrl.isEmpty) {
      if (isRelease || environment != 'development') {
        throw StateError(
          'API_BASE_URL é obrigatória para builds staging e release.',
        );
      }
      return 'http://localhost:3000/api/v1';
    }

    final uri = Uri.tryParse(configuredUrl);
    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw StateError('API_BASE_URL deve ser uma URL absoluta válida.');
    }
    if ((isRelease || environment != 'development') && uri.scheme != 'https') {
      throw StateError('API_BASE_URL deve usar HTTPS em staging e release.');
    }

    return configuredUrl.endsWith('/')
        ? configuredUrl.substring(0, configuredUrl.length - 1)
        : configuredUrl;
  }

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  // Storage Keys
  static const String keyAccessToken = 'jwt_access_token';
  static const String keyRefreshToken = 'jwt_refresh_token';
  static const String keyThemeMode = 'theme_mode_preference';
  static const String keyUserJson = 'user_data_json';
}
