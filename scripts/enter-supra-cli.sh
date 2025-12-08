#!/usr/bin/env bash
set -euo pipefail

# enter-supra-cli.sh
# Enter an interactive shell in the Supra CLI container.

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found. Install Docker to use the Supra CLI container."
  exit 1
fi

CONTAINER_NAME="supra_cli"

echo "Opening interactive shell to container: $CONTAINER_NAME"
docker exec -it "$CONTAINER_NAME" /bin/bash
