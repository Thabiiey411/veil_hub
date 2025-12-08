#!/usr/bin/env bash
# Start Supra CLI container using local compose file
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

docker compose -f docker-compose.supra.yml up -d --build

echo "Supra CLI container started (container name: veil-supra-cli)."

docker ps --filter "name=veil-supra-cli" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
