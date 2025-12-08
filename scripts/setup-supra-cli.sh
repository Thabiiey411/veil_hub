#!/usr/bin/env bash
set -euo pipefail

# setup-supra-cli.sh
# Wrapper to start the Supra CLI docker container using the official compose file.
# This will create a `supra/` directory in the current repository (if missing)
# and start the container named `supra_cli` as defined by the remote compose file.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SUPRA_DIR="$ROOT_DIR/supra"

echo "This script will pull the official Supra CLI docker-compose file and start the container."

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not installed or not on PATH. Install Docker and ensure the daemon is running."
  exit 1
fi

if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose is not available. Install Docker Compose or use Docker Desktop."
  exit 1
fi

mkdir -p "$SUPRA_DIR"
echo "Created/verified supra directory: $SUPRA_DIR"

echo "Fetching remote compose file and starting container (detached)..."

curl -fsSL https://raw.githubusercontent.com/supra-labs/supra-dev-hub/refs/heads/main/Scripts/cli/compose.yaml | docker compose -f - up -d

echo "Container start requested. You can verify with: docker ps --all"
echo "To enter the container shell run: ./scripts/enter-supra-cli.sh"

echo "If you need to stop and remove the container, run: docker compose -f <compose-file> down"

exit 0
