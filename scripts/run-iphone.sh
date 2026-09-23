#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE_ID="${1:-}"
LOCAL_IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)"

if [[ -z "$LOCAL_IP" ]]; then
  echo "Não foi possível descobrir o IP da rede Wi-Fi."
  exit 1
fi

if [[ -z "$DEVICE_ID" ]]; then
  echo "Informe o ID do iPhone. Dispositivos disponíveis:"
  flutter devices
  echo "Uso: ./scripts/run-iphone.sh ID_DO_IPHONE"
  exit 1
fi

if ! curl --silent --fail "http://$LOCAL_IP:3000/api/v1/health" >/dev/null; then
  echo "O backend não está acessível em http://$LOCAL_IP:3000."
  echo "Abra outro Terminal e execute: ./scripts/start-backend-local.sh"
  exit 1
fi

cd "$PROJECT_DIR/apps/mobile"
flutter pub get
cd ios
pod install
cd ..

exec flutter run -d "$DEVICE_ID" \
  --dart-define="API_BASE_URL=http://$LOCAL_IP:3000/api/v1"

