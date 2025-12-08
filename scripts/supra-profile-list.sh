#!/usr/bin/env bash
# List supra profiles inside the supra container
set -euo pipefail
CONTAINER_NAME="veil-supra-cli"

if [ "$(docker ps -q -f name=${CONTAINER_NAME})" = "" ]; then
  echo "Container ${CONTAINER_NAME} is not running. Start it first: ./scripts/start-supra.sh"
  exit 1
fi

docker exec -it ${CONTAINER_NAME} supra profile list
