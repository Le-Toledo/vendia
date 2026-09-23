#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
set -a
source "$PROJECT_DIR/.env"
set +a
cd "$PROJECT_DIR/apps/backend"

npm ci
npx prisma generate
npx prisma migrate deploy

if [[ "${SEED_DEMO:-false}" == "true" ]]; then
  npm run prisma:seed
fi

exec npm run start:dev
