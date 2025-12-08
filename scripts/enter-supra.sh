#!/usr/bin/env bash
# Enter the Supra CLI container shell
set -euo pipefail
CONTAINER_NAME="veil-supra-cli"

if [ "$(docker ps -q -f name=${CONTAINER_NAME})" = "" ]; then
  echo "Container ${CONTAINER_NAME} is not running. Start it first (./scripts/start-supra.sh)"
  exit 1
fi

docker exec -it ${CONTAINER_NAME} /bin/bash
