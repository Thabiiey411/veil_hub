#!/usr/bin/env bash
set -euo pipefail

# supra-profile-import.sh
# Import a private key as a new Supra profile inside the Supra CLI container.
# Usage:
#   ./scripts/supra-profile-import.sh <profile-name> <HEX_PRIVATE_KEY> [--network testnet|mainnet|localnet|custom]
# WARNING: Passing private keys on the command line can be visible in process lists and shell history.
# Prefer providing the key via an environment variable or pasting inside the container interactively.

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <profile-name> <HEX_PRIVATE_KEY> [--network testnet|mainnet|localnet|custom]"
  exit 2
fi

PROFILE_NAME="$1"
PRIVATE_KEY="$2"
shift 2 || true

CONTAINER="supra_cli"

echo "Importing profile '$PROFILE_NAME' inside Supra CLI container ($CONTAINER)..."
docker exec -i "$CONTAINER" supra profile new "$PROFILE_NAME" "$PRIVATE_KEY" "$@"

echo "Done. Use ./scripts/supra-profile-list.sh to view profiles."
