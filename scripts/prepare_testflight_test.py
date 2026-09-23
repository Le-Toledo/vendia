import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location('prepare_testflight', Path(__file__).with_name('prepare-testflight.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class ReleaseConfigTests(unittest.TestCase):
    def config(self, url):
        return {'APP_ENV': 'production', 'API_BASE_URL': url, 'GOOGLE_IOS_CLIENT_ID': 'ios-client.apps.googleusercontent.com', 'GOOGLE_SERVER_CLIENT_ID': 'server-client.apps.googleusercontent.com'}
    def test_rejects_local_and_placeholder_hosts(self):
        for url in ['http://api.vendeai.app/api/v1', 'https://localhost/api/v1', 'https://127.0.0.1/api/v1', 'https://build-validation.invalid/api/v1', 'https://example.com/api/v1']:
            with self.subTest(url=url), self.assertRaises(ValueError): module.validate_defines(self.config(url))
    def test_rejects_secrets_in_mobile_config(self):
        config = self.config('https://api.vendeai.app/api/v1')
        config['JWT_SECRET'] = 'not-a-real-secret'
        with self.assertRaises(ValueError): module.validate_defines(config)
    def test_rejects_credentials_in_url(self):
        with self.assertRaises(ValueError): module.validate_defines(self.config('https://user:pass@api.vendeai.app/api/v1'))
    def test_accepts_valid_shape_without_contacting_service(self):
        self.assertEqual(module.validate_defines(self.config('https://api.vendeai.app/api/v1')), 'https://api.vendeai.app/api/v1')

if __name__ == '__main__': unittest.main()
