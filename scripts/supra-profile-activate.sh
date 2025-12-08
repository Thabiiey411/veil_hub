#!/usr/bin/env bash
set -euo pipefail

# supra-profile-activate.sh
# Activate a Supra profile inside the Supra CLI container.
# Usage:
#   ./scripts/supra-profile-activate.sh <profile-name>

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <profile-name>"
  exit 2
fi

PROFILE_NAME="$1"
CONTAINER="supra_cli"

echo "Activating profile '$PROFILE_NAME' inside Supra CLI container ($CONTAINER)..."
docker exec -it "$CONTAINER" supra profile activate "$PROFILE_NAME"

echo "Done. Active profile will be marked with (*) in ./scripts/supra-profile-list.sh output." 
