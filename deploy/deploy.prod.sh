#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [ ! -f .env.prod ]; then
  echo "Missing .env.prod. Copy env.prod.example and edit secrets."
  exit 1
fi

echo "Bringing up prod stack..."
docker compose --env-file .env.prod up -d --build

echo "Prod stack running. Services:"
docker compose --env-file .env.prod ps
