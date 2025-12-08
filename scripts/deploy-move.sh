#!/usr/bin/env bash
set -euo pipefail

# deploy-move.sh (repo root)
# Moved to repository root so this repository remains the canonical place
# for Move sources and deployment scripts.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MOVE_DIR="$ROOT_DIR/veil-hub-v2/move"
BUILD_DIR="$MOVE_DIR/build"

if [ -z "${NEXT_PUBLIC_SUPRA_TESTNET_RPC:-}" ]; then
  echo "ERROR: NEXT_PUBLIC_SUPRA_TESTNET_RPC is not set. Export it or add to .env.local"
  echo "Example: export NEXT_PUBLIC_SUPRA_TESTNET_RPC=https://rpc-testnet.supra.com"
  exit 1
fi

if [ -z "${SUPRA_PRIVATE_KEY:-}" ]; then
  echo "WARNING: SUPRA_PRIVATE_KEY not set. The script will only build artifacts." 
  DO_DEPLOY=false
else
  DO_DEPLOY=true
fi

echo "Working from $ROOT_DIR"
echo "Move sources: $MOVE_DIR"

if ! command -v jq >/dev/null 2>&1; then
  echo "Please install 'jq' (used for small JSON handling) and re-run."
  exit 1
fi

if [ ! -d "$MOVE_DIR/sources" ]; then
  echo "No Move sources found in $MOVE_DIR/sources. Nothing to do." 
  exit 0
fi

echo "Cleaning previous build artifacts..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "Attempting to build Move modules (best-effort)..."
# Prefer a 'move' tool if available. If not, leave compiled artifacts to CI or manual process.
if command -v move >/dev/null 2>&1; then
  echo "Found 'move' tool. Running 'move build' inside move/"
  (cd "$MOVE_DIR" && move build --install-dir "$BUILD_DIR") || true
else
  echo "No 'move' tool found. Skipping compilation step. You can compile locally or in CI."
fi

echo "Build artifacts (if any) are available under: $BUILD_DIR"

if [ "$DO_DEPLOY" = false ]; then
  echo "Deployment skipped (no SUPRA_PRIVATE_KEY). To deploy, set SUPRA_PRIVATE_KEY env var."
  echo "This script does not attempt to send private keys to remote services."
  exit 0
fi

echo "Preparing to deploy to: $NEXT_PUBLIC_SUPRA_TESTNET_RPC"

# Placeholder: request account funding from the testnet faucet (optional)
if [ -n "${NEXT_PUBLIC_SUPRA_TESTNET_FAUCET:-}" ]; then
  if [ -n "${SUPRA_DEPLOY_ACCOUNT:-}" ]; then
    echo "Requesting faucet funds for $SUPRA_DEPLOY_ACCOUNT"
    curl -sS -X POST "$NEXT_PUBLIC_SUPRA_TESTNET_FAUCET/$SUPRA_DEPLOY_ACCOUNT" || true
  fi
fi

echo "To perform the actual publish step, the script will attempt to use a configured CLI."
echo "It supports two modes (in order of preference):"
echo "  1) If environment variable SUPRA_CLI_CMD is provided, the script will run it (useful for CI where you provide the full CLI command as a secret)."
echo "  2) If 'supra' is on PATH, the script will run the recommended 'supra move' compile/publish flow."

if [ -n "${SUPRA_CLI_CMD:-}" ]; then
  echo "Running SUPRA_CLI_CMD (from env/secret)..."
  echo "Command (redacted): ***supra-cmd***"
  # Run the supplied command. Expand variables in the command if present.
  eval "$SUPRA_CLI_CMD"
  echo "SUPRA_CLI_CMD finished."
  exit 0
fi

if command -v supra >/dev/null 2>&1; then
  echo "Found 'supra' CLI on PATH. Using it to compile and publish the Move package."

  echo "Compiling Move package..."
  supra move tool compile --package-dir "$MOVE_DIR" || {
    echo "supra move tool compile failed. Aborting."
    exit 1
  }

  # Optionally request faucet funds (best-effort)
  if [ -n "${NEXT_PUBLIC_SUPRA_TESTNET_FAUCET:-}" ]; then
    echo "Requesting testnet faucet funds (best-effort)..."
    if [ -n "${SUPRA_DEPLOY_ACCOUNT:-}" ]; then
      supra move account fund-with-faucet --rpc-url "$NEXT_PUBLIC_SUPRA_TESTNET_RPC" --account "$SUPRA_DEPLOY_ACCOUNT" || true
    else
      supra move account fund-with-faucet --rpc-url "$NEXT_PUBLIC_SUPRA_TESTNET_RPC" || true
    fi
  fi

  echo "Publishing Move package..."
  if [ -n "${SUPRA_PRIVATE_KEY:-}" ]; then
    supra move tool publish --package-dir "$MOVE_DIR" --rpc-url "$NEXT_PUBLIC_SUPRA_TESTNET_RPC" --private-key "$SUPRA_PRIVATE_KEY" || {
      echo "supra move tool publish failed."
      exit 1
    }
  else
    supra move tool publish --package-dir "$MOVE_DIR" --rpc-url "$NEXT_PUBLIC_SUPRA_TESTNET_RPC" || {
      echo "supra move tool publish failed."
      exit 1
    }
  fi

  echo "Publish completed."
  exit 0
fi

echo "ERROR: No deploy command configured and 'supra' CLI not found on PATH."
echo "Options to proceed:"
echo "  - Install the 'supra' CLI in your environment or CI image, OR"
echo "  - Set the 'SUPRA_CLI_CMD' secret with the exact publish command to run (recommended for CI)."
echo "Example SUPRA_CLI_CMD (do not commit):"
echo "  supra move tool compile --package-dir $MOVE_DIR && supra move account fund-with-faucet --rpc-url $NEXT_PUBLIC_SUPRA_TESTNET_RPC && supra move tool publish --package-dir $MOVE_DIR --rpc-url $NEXT_PUBLIC_SUPRA_TESTNET_RPC"

exit 1
