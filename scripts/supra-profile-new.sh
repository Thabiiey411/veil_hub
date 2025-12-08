#!/usr/bin/env bash
# Create a new Supra profile (or import a private key) inside the supra container
set -euo pipefail
CONTAINER_NAME="veil-supra-cli"

usage() {
  cat <<EOF
Usage: $0 <profile-name> [private-key] [network]

Examples:
  # Generate a new profile named accountA on testnet
  $0 accountA

  # Import an existing private key into profile "accountB" on testnet
  $0 accountB "0x012345..." testnet

If network is omitted, defaults to 'testnet'.
EOF
}

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

PROFILE_NAME="$1"
PRIVATE_KEY="${2:-}"
NETWORK="${3:-testnet}"

# ensure container is running
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" = "" ]; then
  echo "Container ${CONTAINER_NAME} is not running. Start it first: ./scripts/start-supra.sh"
  exit 1
fi

if [ -n "$PRIVATE_KEY" ]; then
  echo "Importing private key into profile '${PROFILE_NAME}' on network '${NETWORK}'"
  docker exec -it ${CONTAINER_NAME} supra profile new "$PROFILE_NAME" "$PRIVATE_KEY" --network "$NETWORK"
else
  echo "Generating new profile '${PROFILE_NAME}' on network '${NETWORK}'"
  docker exec -it ${CONTAINER_NAME} supra profile new "$PROFILE_NAME" --network "$NETWORK"
fi

echo "Profile command finished. To view profiles run: ./scripts/supra-profile-list.sh"
