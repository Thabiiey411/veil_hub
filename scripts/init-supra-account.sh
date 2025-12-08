#!/usr/bin/env bash
set -euo pipefail

# init-supra-account.sh
# Automated script to initialize a Supra account, request testnet funds, and prepare for deployment.
# This script performs the steps from QUICKSTART_DEPLOYMENT.md in one go.

PROFILE_NAME="${1:-accountA}"
NETWORK="${2:-testnet}"

if [ -z "$PROFILE_NAME" ]; then
  echo "Usage: $0 [PROFILE_NAME] [NETWORK]"
  echo "  PROFILE_NAME: defaults to 'accountA'"
  echo "  NETWORK: defaults to 'testnet' (can be testnet, mainnet, localnet, custom)"
  exit 1
fi

CONTAINER="supra_cli"
RPC_URL="https://rpc-testnet.supra.com"

echo "===== Supra Account Initialization ====="
echo "Profile name: $PROFILE_NAME"
echo "Network: $NETWORK"
echo "Container: $CONTAINER"
echo ""

# Check if container is running
if ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER}$"; then
  echo "ERROR: Container '$CONTAINER' is not running."
  echo "Start it with: ./scripts/setup-supra-cli.sh"
  exit 1
fi

# Step 1: Create profile
echo "[1/4] Creating profile '$PROFILE_NAME'..."
docker exec -it "$CONTAINER" supra profile new "$PROFILE_NAME" --network "$NETWORK"

# Step 2: Activate profile
echo ""
echo "[2/4] Activating profile..."
docker exec -it "$CONTAINER" supra profile activate "$PROFILE_NAME"

# Step 3: List profiles
echo ""
echo "[3/4] Current profiles:"
docker exec "$CONTAINER" supra profile -l

# Step 4: Fund from faucet (testnet only)
if [ "$NETWORK" = "testnet" ]; then
  echo ""
  echo "[4/4] Requesting testnet funds from faucet..."
  docker exec -it "$CONTAINER" supra move account fund-with-faucet --rpc-url "$RPC_URL" || {
    echo "WARNING: Faucet request may have failed. You can retry with:"
    echo "  ./scripts/enter-supra-cli.sh"
    echo "  supra move account fund-with-faucet --rpc-url $RPC_URL"
  }
else
  echo ""
  echo "[4/4] Skipping faucet (not testnet). You must fund '$PROFILE_NAME' manually."
fi

echo ""
echo "===== Setup Complete ====="
echo "Profile '$PROFILE_NAME' is now active and ready for deployment."
echo ""
echo "Next steps:"
echo "  1. Compile: supra move tool compile --package-dir ./veil-hub-v2/move"
echo "  2. Publish:  supra move tool publish --package-dir ./veil-hub-v2/move --rpc-url $RPC_URL"
echo ""
echo "Or run the container shell to execute directly:"
echo "  ./scripts/enter-supra-cli.sh"
echo ""
echo "For CI/CD deployment, add these secrets to GitHub:"
echo "  - SUPRA_PRIVATE_KEY: $(docker exec "$CONTAINER" supra profile -l -r 2>/dev/null | grep -A1 "$PROFILE_NAME" | tail -1 || echo '[run inside container: supra profile -l -r]')"
echo "  - NEXT_PUBLIC_SUPRA_TESTNET_RPC: $RPC_URL"
echo ""

