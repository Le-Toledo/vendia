#!/usr/bin/env python3
"""Validate the real API, configure Google iOS and build an archive without uploading."""
import argparse
import ipaddress
import json
import plistlib
import re
import subprocess
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parents[1]
MOBILE = ROOT / 'apps/mobile'

def validate_defines(data):
    allowed = {'APP_ENV', 'API_BASE_URL', 'GOOGLE_IOS_CLIENT_ID', 'GOOGLE_SERVER_CLIENT_ID'}
    if set(data) - allowed:
        raise ValueError('O arquivo aceita apenas os quatro parâmetros públicos documentados; não coloque secrets nele.')
    if data.get('APP_ENV') != 'production':
        raise ValueError('APP_ENV deve ser production.')
    url = urlparse(data.get('API_BASE_URL', ''))
    host = url.hostname or ''
    if url.scheme != 'https' or not host or url.username or url.password or url.query or url.fragment:
        raise ValueError('API_BASE_URL deve ser uma URL HTTPS pública, sem credenciais ou parâmetros.')
    if host == 'localhost' or host.endswith(('.local', '.invalid', '.test', '.example')) or host in {'example.com', 'example.org', 'example.net'}:
        raise ValueError('Configure a API real; endereços locais ou ilustrativos não podem ser distribuídos.')
    try:
        address = ipaddress.ip_address(host)
    except ValueError:
        address = None
    if address and not address.is_global:
        raise ValueError('A API precisa ser acessível fora da rede local.')
    for name in ['GOOGLE_IOS_CLIENT_ID', 'GOOGLE_SERVER_CLIENT_ID']:
        if not re.fullmatch(r'[a-zA-Z0-9-]+\.apps\.googleusercontent\.com', data.get(name, '')):
            raise ValueError(f'Configure {name} com o ID público do cliente OAuth correspondente.')
    return data['API_BASE_URL'].rstrip('/')

def fetch_json(url):
    with urlopen(url, timeout=20) as response:
        if urlparse(response.url).scheme != 'https':
            raise ValueError('A API redirecionou para uma conexão sem HTTPS.')
        return json.load(response)['data']

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('config', type=Path, help='JSON local com os quatro parâmetros públicos')
    parser.add_argument('--build-number', required=True, type=int)
    parser.add_argument('--check-only', action='store_true')
    parser.add_argument('--unsigned', action='store_true', help='Gera archive sem assinatura; não gera IPA distribuível')
    args = parser.parse_args()
    try:
        if args.build_number < 1: raise ValueError('O número do build deve ser positivo e novo no App Store Connect.')
        config = json.loads(args.config.read_text())
        api = validate_defines(config)
        if fetch_json(api + '/health/ready').get('status') != 'ready':
            raise ValueError('API ou banco de dados indisponível.')
        remote = fetch_json(api + '/app/config')
        if not remote.get('passwordResetEnabled'): raise ValueError('Configure a entrega real de emails no servidor.')
        if not remote.get('appleAuthEnabled'): raise ValueError('Configure Sign in with Apple no servidor antes da distribuição iOS.')
        if not remote.get('googleAuthEnabled'): raise ValueError('Habilite e configure Google OAuth no servidor.')
        if remote.get('ai', {}).get('id') == 'mock': raise ValueError('O servidor ainda está usando IA simulada.')
        if remote.get('privacy', {}).get('contact') != 'vendeai.suport@gmail.com':
            raise ValueError('Confira o contato público na política do servidor.')
        with urlopen(api + '/app/privacy', timeout=20) as response:
            if 'text/html' not in response.headers.get('Content-Type', ''): raise ValueError('Política pública indisponível.')
        print('API, banco, configuração de email e política acessíveis. Nenhum email de teste foi enviado.')
        if args.check_only: return
        client = config['GOOGLE_IOS_CLIENT_ID']
        reverse = '.'.join(reversed(client.split('.')))
        for filename in ['Info.plist', 'Info-Debug.plist']:
            path = MOBILE / 'ios/Runner' / filename
            info = plistlib.loads(path.read_bytes())
            info['GIDClientID'] = client
            info['GIDServerClientID'] = config['GOOGLE_SERVER_CLIENT_ID']
            urls = [item for item in info.get('CFBundleURLTypes', []) if item.get('CFBundleURLName') != 'google-oauth']
            urls.append({'CFBundleURLName': 'google-oauth', 'CFBundleTypeRole': 'Editor', 'CFBundleURLSchemes': [reverse]})
            info['CFBundleURLTypes'] = urls
            path.write_bytes(plistlib.dumps(info, sort_keys=False))
        for command in [
            ['flutter', 'pub', 'get', '--enforce-lockfile'],
            ['flutter', 'analyze', '--no-pub'],
            ['flutter', 'test', '--no-pub'],
            ['flutter', 'build', 'ipa', '--release', '--no-pub', f'--build-number={args.build_number}', f'--dart-define-from-file={args.config.resolve()}'] + (['--no-codesign'] if args.unsigned else []),
        ]:
            subprocess.run(command, cwd=MOBILE, check=True)
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError) as error:
        # Never print a response body or a secret-bearing configuration.
        print(str(error) if isinstance(error, ValueError) else 'Preparação interrompida. Verifique a configuração, conectividade e a etapa que falhou.')
        raise SystemExit(1)

if __name__ == '__main__': main()
