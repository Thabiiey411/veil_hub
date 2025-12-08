#!/usr/bin/env bash
set -euo pipefail

# supra-profile-list.sh
# List existing Supra profiles. Use -r to also reveal private keys (use with care).
# Usage:
#   ./scripts/supra-profile-list.sh        # lists profiles
#   ./scripts/supra-profile-list.sh -r     # lists profiles and reveals private keys

REVEAL_FLAG=""
if [ "${1:-}" = "-r" ]; then
  REVEAL_FLAG="-r"
fi

CONTAINER="supra_cli"

echo "Listing Supra profiles inside container ($CONTAINER)..."
docker exec -it "$CONTAINER" supra profile $REVEAL_FLAG -l
#!/usr/bin/env bash
# List supra profiles inside the supra container
set -euo pipefail
CONTAINER_NAME="veil-supra-cli"

if [ "$(docker ps -q -f name=${CONTAINER_NAME})" = "" ]; then
  echo "Container ${CONTAINER_NAME} is not running. Start it first: ./scripts/start-supra.sh"
  exit 1
fi

docker exec -it ${CONTAINER_NAME} supra profile list
