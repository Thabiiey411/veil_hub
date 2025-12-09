# Supra Contract Deployment Guide

## ✅ Current Status

- **Supra CLI Container:** Running (`supra_cli`)
- **Container Image:** `asia-docker.pkg.dev/supra-devnet-misc/supra-testnet/validator-node:v9.0.12`
- **Smart Contracts:** 26 Move modules ready
- **Target Network:** Supra Testnet (Chain ID: 6)
- **RPC Endpoint:** `https://rpc-testnet.supra.com`

---

## Contract Compilation

### Inside Container

```bash
# Enter the container shell
docker exec -it supra_cli /bin/bash

# Compile VeilHub contracts
supra move tool compile \
  --package-dir /workspace/supra/move_workspace/VeilHub

# Expected output:
# Compiling VeilHub package
# Warning/Error codes (if any)
# Generated: /workspace/supra/move_workspace/VeilHub/build/
```

### From Host

```bash
docker exec supra_cli supra move tool compile \
  --package-dir /workspace/supra/move_workspace/VeilHub
```

---

## Account Setup

### Initialize Account on Testnet

```bash
# From container
docker exec supra_cli bash -c "
  supra account init accountA testnet && \
  supra account list
"

# Expected output:
# Created account: accountA
# Network: testnet
# Address: [0x...]
# Balance: 0 (needs to be funded)
```

### Fund Account (Testnet Faucet)

```bash
# Get account address
docker exec supra_cli bash -c "
  supra account list | grep accountA
"

# Fund via testnet faucet (manual):
# 1. Visit: https://faucet.testnet.supra.com
# 2. Enter your address
# 3. Claim 10 TEST SUP tokens
```

---

## Contract Publishing

### Method 1: From Host (Recommended)

```bash
# Compile
docker exec supra_cli supra move tool compile \
  --package-dir /workspace/supra/move_workspace/VeilHub

# Publish to testnet
docker exec supra_cli supra move tool publish \
  --package-dir /workspace/supra/move_workspace/VeilHub \
  --account accountA \
  --rpc-url https://rpc-testnet.supra.com

# Expected output:
# Publishing package VeilHub...
# Transaction: 0x[...]
# Status: Success
```

### Method 2: Interactive (From Container)

```bash
docker exec -it supra_cli /bin/bash

# Inside container:
cd /workspace/supra/move_workspace/VeilHub

# Compile
supra move tool compile

# Publish
supra move tool publish \
  --account accountA \
  --rpc-url https://rpc-testnet.supra.com
```

---

## Deployment Script

Create `/workspaces/veil_hub/deploy-supra-contracts.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

CONTAINER="supra_cli"
PACKAGE_DIR="/workspace/supra/move_workspace/VeilHub"
ACCOUNT="${1:-accountA}"
TESTNET_RPC="https://rpc-testnet.supra.com"

echo "=== Supra Contract Deployment ==="
echo "Container: $CONTAINER"
echo "Package: $PACKAGE_DIR"
echo "Account: $ACCOUNT"
echo "Network: Testnet"
echo ""

# Check container is running
if ! docker ps --filter "name=$CONTAINER" --format "{{.Names}}" | grep -q "$CONTAINER"; then
  echo "ERROR: Container $CONTAINER is not running"
  echo "Start with: bash /workspaces/veil_hub/scripts/setup-supra-cli.sh"
  exit 1
fi

echo "✓ Container running"

# Compile contracts
echo ""
echo "Step 1: Compiling contracts..."
if docker exec "$CONTAINER" supra move tool compile --package-dir "$PACKAGE_DIR"; then
  echo "✓ Compilation successful"
else
  echo "✗ Compilation failed"
  exit 1
fi

# Check account exists
echo ""
echo "Step 2: Verifying account..."
if docker exec "$CONTAINER" supra account list | grep -q "$ACCOUNT"; then
  echo "✓ Account '$ACCOUNT' found"
else
  echo "✗ Account '$ACCOUNT' not found"
  echo "Create with: docker exec $CONTAINER supra account init $ACCOUNT testnet"
  exit 1
fi

# Publish contracts
echo ""
echo "Step 3: Publishing contracts to testnet..."
if docker exec "$CONTAINER" supra move tool publish \
  --package-dir "$PACKAGE_DIR" \
  --account "$ACCOUNT" \
  --rpc-url "$TESTNET_RPC"; then
  echo "✓ Publishing successful"
else
  echo "✗ Publishing failed"
  exit 1
fi

# Verify
echo ""
echo "Step 4: Verifying deployment..."
ACCOUNT_ADDR=$(docker exec "$CONTAINER" supra account list | grep "$ACCOUNT" | awk '{print $2}')
echo "Account address: $ACCOUNT_ADDR"

echo ""
echo "=== Deployment Complete ==="
echo "Check contracts: https://testnet.supra.com/address/$ACCOUNT_ADDR"
```

---

## Contract Verification

### Check Deployed Objects

```bash
# Get account address
ACCOUNT_ADDR=$(docker exec supra_cli bash -c "
  supra account list | grep accountA | awk '{print \$2}'
")

# List objects
docker exec supra_cli supra move object list \
  --address $ACCOUNT_ADDR \
  --rpc-url https://rpc-testnet.supra.com

# Expected output:
# Objects owned by [address]:
# 0x[hash]: VeilCoin
# 0x[hash]: StakingPool
# 0x[hash]: LiquidityPool
# ... (26 modules total)
```

### Check Transaction

```bash
# After publishing, use the transaction hash
TXID="0x..."

docker exec supra_cli supra client call \
  --rpc-url https://rpc-testnet.supra.com \
  tx \
  $TXID
```

---

## Smart Contracts Overview

### Veil Finance Ecosystem (26 Modules)

**Core Infrastructure:**
- `veil_coin.move` - Native VEIL token (1B supply, 100M floor)
- `burn_controller.move` - Token burn mechanism (50% of revenue)

**DeFi Protocols:**
- `amm.move` - Automated Market Maker (DEX)
- `lending_pool.move` - Lending/borrowing protocol
- `staking_pool.move` - Yield farming

**Advanced Features:**
- `governance.move` - Voting & governance
- `indices.move` - Synthetic indices
- `yield_aggregator.move` - Multi-strategy yield

**Monitoring & Security:**
- `price_oracle.move` - Price feeds
- `risk_manager.move` - Risk controls
- `event_emitter.move` - Contract events

---

## Troubleshooting

### "Account not found"
```bash
# Create account
docker exec supra_cli supra account init accountA testnet

# Verify
docker exec supra_cli supra account list
```

### "Insufficient balance"
```bash
# Fund account via https://faucet.testnet.supra.com
# Or transfer from another account:
docker exec supra_cli supra client call \
  --account accountA \
  --function transfer \
  --args <recipient_address> 1000000
```

### "Module already exists"
```bash
# Try different module name or update version
# Edit: /workspace/supra/move_workspace/VeilHub/Move.toml
# Change: version = "0.0.1" → "0.0.2"
```

### "Compilation errors"
```bash
# Check Move.toml
docker exec supra_cli cat /workspace/supra/move_workspace/VeilHub/Move.toml

# Check source files
docker exec supra_cli ls /workspace/supra/move_workspace/VeilHub/sources/
```

---

## Network Information

| Parameter | Value |
|-----------|-------|
| **Chain ID** | 6 |
| **RPC URL** | https://rpc-testnet.supra.com |
| **Faucet** | https://faucet.testnet.supra.com |
| **Explorer** | https://testnet.supra.com |
| **Native Token** | SUP (Supra Utility Protocol) |
| **Gas Token** | SUP |

---

## Quick Deploy Commands

```bash
# Complete deployment in one command
docker exec supra_cli bash -c "
  supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub && \
  supra account init accountA testnet 2>/dev/null || true && \
  supra move tool publish \
    --package-dir /workspace/supra/move_workspace/VeilHub \
    --account accountA \
    --rpc-url https://rpc-testnet.supra.com
"

# With logging
docker exec supra_cli bash -c "
  echo 'Compiling...' && \
  supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub 2>&1 && \
  echo 'Publishing...' && \
  supra move tool publish \
    --package-dir /workspace/supra/move_workspace/VeilHub \
    --account accountA \
    --rpc-url https://rpc-testnet.supra.com 2>&1
" | tee /tmp/deployment.log
```

---

## Related Files

- **Setup:** `/workspaces/veil_hub/scripts/setup-supra-cli.sh`
- **Account Init:** `/workspaces/veil_hub/scripts/init-supra-account.sh`
- **Contracts:** `/workspaces/veil_hub/supra/move_workspace/VeilHub/sources/`
- **Tests:** `/workspaces/veil_hub/supra/veil_testnet/`

---

**Last Updated:** $(date +'%Y-%m-%d %H:%M:%S')
**CLI Version:** v9.0.12 (Supra Testnet)
**Status:** ✅ Ready to deploy
