import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/constants/app_constants.dart';

void main() {
  String resolve(
    String url, {
    String environment = 'development',
    bool release = false,
  }) => AppConstants.resolveApiBaseUrl(
    environment: environment,
    configuredUrl: url,
    isRelease: release,
  );

  test('local development keeps its existing default', () {
    expect(resolve(''), 'http://localhost:3000/api/v1');
    expect(
      resolve('http://192.168.1.2:3000/api/v1/'),
      'http://192.168.1.2:3000/api/v1',
    );
  });
  test(
    'release requires an explicit HTTPS API even with development default',
    () {
      expect(() => resolve('', release: true), throwsStateError);
      expect(
        () => resolve('http://example.com/api/v1', release: true),
        throwsStateError,
      );
      expect(
        resolve(' https://example.com/api/v1/ ', release: true),
        'https://example.com/api/v1',
      );
    },
  );
  test('staging and production reject empty or insecure API URLs', () {
    for (final environment in ['staging', 'production']) {
      expect(() => resolve('', environment: environment), throwsStateError);
      expect(
        () => resolve('http://example.com', environment: environment),
        throwsStateError,
      );
    }
  });
  test('reject malformed URLs and credentials embedded in a URL', () {
    for (final url in [
      'relative/path',
      'ftp://example.com',
      'https://user:pass@example.com',
      'https://example.com?token=value',
      'https://example.com#fragment',
    ]) {
      expect(() => resolve(url), throwsStateError);
    }
    expect(
      () => resolve('https://example.com', environment: 'invalid'),
      throwsStateError,
    );
  });
}
