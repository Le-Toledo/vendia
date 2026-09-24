import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.companyName,
    this.cpfCnpj,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.logoUrl,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String name;
  final String? companyName;
  final String? cpfCnpj;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? logoUrl;
  final String? avatarUrl;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final profile =
        json['profile'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: profile['fullName'] as String? ?? '',
      companyName: profile['companyName'] as String?,
      cpfCnpj: profile['cpfCnpj'] as String?,
      phone: profile['phone'] as String?,
      address: profile['address'] as String?,
      city: profile['city'] as String?,
      state: profile['state'] as String?,
      zipCode: profile['zipCode'] as String?,
      logoUrl: profile['logoUrl'] as String?,
      avatarUrl: profile['avatarUrl'] as String?,
    );
  }
}

class AuthRepository {
  AuthRepository(this.api);
  final ApiClient api;
  bool _googleInitialized = false;

  Future<AuthUser> login(String email, String password) =>
      _authenticate('/auth/login', {'email': email, 'password': password});
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    String? company,
  }) => _authenticate('/auth/register', {
    'fullName': name,
    'email': email,
    'password': password,
    if (company?.isNotEmpty == true) 'companyName': company,
  });

  Future<AuthUser> loginWithApple() async {
    final generation = await api.beginSessionChange();
    final random = Random.secure();
    final nonce = List.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
      nonce: sha256.convert(utf8.encode(nonce)).toString(),
    );
    return _authenticate('/auth/apple', {
      'authorizationCode': credential.authorizationCode,
      'nonce': nonce,
    }, generation: generation);
  }

  Future<AuthUser> loginWithGoogle() async {
    final generation = await api.beginSessionChange();
    if (AppConstants.googleServerClientId.isEmpty) {
      throw const ApiException(
        'Login Google não configurado neste aplicativo.',
      );
    }
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConstants.googleServerClientId,
        clientId: AppConstants.googleIosClientId.isEmpty
            ? null
            : AppConstants.googleIosClientId,
      );
      _googleInitialized = true;
    }
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const ApiException('O Google não retornou um token de identidade.');
    }
    return _authenticate('/auth/google', {
      'idToken': idToken,
    }, generation: generation);
  }

  Future<AuthUser> restore() async {
    final generation = api.sessionGeneration;
    if (!await api.hasStoredSession(generation)) {
      throw const ApiException('Sessão não encontrada');
    }
    final response = await api.dio.get(
      '/users/me',
      options: Options(extra: {ApiClient.generationKey: generation}),
    );
    return AuthUser.fromJson(api.unwrap<Map<String, dynamic>>(response));
  }

  Future<void> logout() => api.logout();

  Future<void> deleteAccount() async {
    final generation = api.sessionGeneration;
    try {
      await api.dio.delete(
        '/users/me',
        data: {'confirmation': 'EXCLUIR'},
        options: Options(extra: {ApiClient.generationKey: generation}),
      );
      await api.beginSessionChange(expectedGeneration: generation);
    } catch (error) {
      throw api.readableError(error);
    }
  }

  Future<void> clearLocalSession() async {
    await api.beginSessionChange();
  }

  Future<AuthUser> _authenticate(
    String path,
    Map<String, dynamic> body, {
    int? generation,
  }) async {
    try {
      final current = generation ?? await api.beginSessionChange();
      final response = await api.dio.post(
        path,
        data: body,
        options: Options(extra: {ApiClient.generationKey: current}),
      );
      final data = api.unwrap<Map<String, dynamic>>(response);
      final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = data['tokens'] as Map<String, dynamic>;
      await api.acceptSession(
        current,
        tokens['accessToken'] as String,
        tokens['refreshToken'] as String,
      );
      return user;
    } catch (error) {
      throw api.readableError(error);
    }
  }
}
