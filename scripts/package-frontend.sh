#!/usr/bin/env bash
set -euo pipefail

# package-frontend.sh
# Create a frontend-only archive for transferring to the dedicated frontend repo
# (https://github.com/Thabiiey411beta/veil_hub2). Excludes Move sources and
# contract-related files so this repository remains the canonical contract repo.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FRONTEND_DIR="$ROOT/veil-hub-v2"
OUT="$ROOT/veil-hub-v2-frontend.tar.gz"

if [ ! -d "$FRONTEND_DIR" ]; then
  echo "Frontend directory not found: $FRONTEND_DIR"
  exit 1
fi

echo "Creating frontend archive: $OUT"

tar --exclude-vcs \
    --exclude='./veil-hub-v2/.git' \
    --exclude='./veil-hub-v2/node_modules' \
    --exclude='./veil-hub-v2/.next' \
    --exclude='./veil-hub-v2/move' \
    --exclude='./veil-hub-v2/supra' \
    --exclude='./veil-hub-v2/scripts/deploy-move.sh' \
    --exclude='./veil-hub-v2/.github/workflows/deploy-move.yml' \
    -C "$ROOT" -czf "$OUT" "veil-hub-v2"

echo "Archive created: $OUT"
echo "Next steps: upload this archive to the frontend repository (veil_hub2) and unpack in the repo root." 
