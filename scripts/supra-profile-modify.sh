#!/usr/bin/env bash
set -euo pipefail

# supra-profile-modify.sh
# Modify an existing Supra profile's network settings.
# Usage:
#   ./scripts/supra-profile-modify.sh <profile-name> --network <localnet|testnet|mainnet|custom>

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <profile-name> --network <localnet|testnet|mainnet|custom>"
  exit 2
fi

PROFILE_NAME="$1"
shift || true

CONTAINER="supra_cli"

echo "Modifying profile '$PROFILE_NAME' inside Supra CLI container ($CONTAINER)..."
docker exec -it "$CONTAINER" supra profile modify "$PROFILE_NAME" "$@"

echo "Done. Use ./scripts/supra-profile-list.sh to verify changes."
