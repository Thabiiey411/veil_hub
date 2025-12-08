#!/usr/bin/env bash
# Stop and remove Supra CLI container and network
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

docker compose -f docker-compose.supra.yml down

echo "Supra CLI services stopped and removed." 
