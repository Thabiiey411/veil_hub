#!/usr/bin/env bash
# Run profile migration command inside supra container (if upgrading)
set -euo pipefail
CONTAINER_NAME="veil-supra-cli"

if [ "$(docker ps -q -f name=${CONTAINER_NAME})" = "" ]; then
  echo "Container ${CONTAINER_NAME} is not running. Start it first: ./scripts/start-supra.sh"
  exit 1
fi

echo "Running profile migration inside container..."
docker exec -it ${CONTAINER_NAME} supra profile migrate

echo "Migration command finished. Inspect profiles with: ./scripts/supra-profile-list.sh"
