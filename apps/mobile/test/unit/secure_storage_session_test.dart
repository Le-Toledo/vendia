import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/constants/app_constants.dart';
import 'package:vendeai_mobile/core/storage/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test(
    'new installation removes surviving Keychain credentials only',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        AppConstants.keyAccessToken: 'legacy-a',
        AppConstants.keyRefreshToken: 'legacy-refresh-a',
        AppConstants.keyUserJson: '{"id":"a"}',
        SecureStorageService.sessionKey: jsonEncode({
          'accessToken': 'a',
          'refreshToken': 'a-refresh',
        }),
        'unrelated-key': 'keep',
      });
      final storage = SecureStorageService();
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      final remaining = await const FlutterSecureStorage().readAll();
      expect(remaining, {'unrelated-key': 'keep'});
      expect(
        (await SharedPreferences.getInstance()).getBool(
          SecureStorageService.installationKey,
        ),
        isTrue,
      );
    },
  );

  test(
    'normal relaunch keeps the session; reinstall rejects surviving Keychain data',
    () async {
      await SecureStorageService().saveTokens(
        accessToken: 'b',
        refreshToken: 'b-refresh',
      );
      expect(await SecureStorageService().getAccessToken(), 'b');
      // Simulate deletion of the app sandbox while the Keychain survives.
      SharedPreferences.setMockInitialValues({});
      expect(await SecureStorageService().getAccessToken(), isNull);
      expect(await SecureStorageService().getRefreshToken(), isNull);
    },
  );

  test(
    'token pair is one item and logout preserves unrelated preferences',
    () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final storage = SecureStorageService();
      await storage.saveTokens(accessToken: 'b', refreshToken: 'b-refresh');
      final values = await const FlutterSecureStorage().readAll();
      expect(values.keys, [SecureStorageService.sessionKey]);
      expect(jsonDecode(values.values.single), {
        'accessToken': 'b',
        'refreshToken': 'b-refresh',
      });
      await storage.clearAll();
      expect(await storage.getAccessToken(), isNull);
      expect(
        (await SharedPreferences.getInstance()).getString('theme_mode'),
        'dark',
      );
      expect(
        (await SharedPreferences.getInstance()).getBool(
          SecureStorageService.installationKey,
        ),
        isTrue,
      );
    },
  );
}
