import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  SecureStorageService({
    FlutterSecureStorage? storage,
    Future<SharedPreferences> Function()? preferences,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _preferences = preferences ?? SharedPreferences.getInstance;

  // Preferences belong to the app installation, unlike the iOS Keychain.
  // The first upgrade to this policy deliberately requires a fresh login too.
  static const installationKey = 'auth_installation_v2';
  static const sessionKey = 'auth_session_v2';
  final FlutterSecureStorage _storage;
  final Future<SharedPreferences> Function() _preferences;
  Future<void>? _initialization;

  Future<void> _initialize() => _initialization ??= _initializeInstallation();

  Future<void> _initializeInstallation() async {
    final preferences = await _preferences();
    if (preferences.getBool(installationKey) != true) {
      await _deleteSessionKeys();
      if (!await preferences.setBool(installationKey, true)) {
        throw StateError('Não foi possível inicializar a sessão local.');
      }
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _initialize();
    // A single Keychain item prevents partially updated access/refresh pairs.
    await _storage.write(
      key: sessionKey,
      value: jsonEncode({
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      }),
    );
  }

  Future<Map<String, dynamic>?> _readSession() async {
    await _initialize();
    final value = await _storage.read(key: sessionKey);
    if (value == null) return null;
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic> ||
        decoded['accessToken'] is! String ||
        decoded['refreshToken'] is! String ||
        (decoded['accessToken'] as String).isEmpty ||
        (decoded['refreshToken'] as String).isEmpty) {
      throw StateError('Sessão local inválida.');
    }
    return decoded;
  }

  Future<String?> getAccessToken() async =>
      (await _readSession())?['accessToken'] as String?;

  Future<String?> getRefreshToken() async =>
      (await _readSession())?['refreshToken'] as String?;

  Future<void> clearAll() async {
    await _initialize();
    await _deleteSessionKeys();
  }

  Future<void> _deleteSessionKeys() async {
    // Never delete unrelated Keychain entries or the installation marker.
    for (final key in [
      sessionKey,
      AppConstants.keyAccessToken,
      AppConstants.keyRefreshToken,
      AppConstants.keyUserJson,
    ]) {
      await _storage.delete(key: key);
    }
  }
}
