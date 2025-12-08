#!/bin/bash
# Supra CLI Deployment Script
# This script builds and deploys contracts to Supra network

set -e

# Configuration
NETWORK="${1:-testnet}"  # testnet or mainnet
SUPRA_CLI="${SUPRA_CLI:-supra}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Supra Contract Deployment Script ===${NC}"
echo "Network: $NETWORK"
echo ""

# Check if supra CLI is available
if ! command -v $SUPRA_CLI &> /dev/null; then
    echo -e "${RED}Error: supra CLI not found. Please ensure it's installed and in PATH.${NC}"
    exit 1
fi

# Display supra version
echo -e "${BLUE}Supra CLI Version:${NC}"
$SUPRA_CLI --version
echo ""

# Navigate to move directory
cd "$(dirname "$0")/veil-hub-v2/move"
echo -e "${BLUE}Working directory: $(pwd)${NC}"
echo ""

# Step 1: Build contracts
echo -e "${BLUE}=== Step 1: Building Move Contracts ===${NC}"
if $SUPRA_CLI build; then
    echo -e "${GREEN}✓ Build successful${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
echo ""

# Step 2: Test contracts (optional)
echo -e "${BLUE}=== Step 2: Testing Contracts ===${NC}"
if $SUPRA_CLI test; then
    echo -e "${GREEN}✓ Tests passed${NC}"
else
    echo -e "${RED}⚠ Tests failed (continuing anyway)${NC}"
fi
echo ""

# Step 3: Deploy contracts
echo -e "${BLUE}=== Step 3: Deploying Contracts to $NETWORK ===${NC}"

# Set network-specific configuration
case $NETWORK in
    testnet)
        RPC_URL="https://rpc-testnet.supra.com"
        CHAIN_ID="6"
        ;;
    mainnet)
        RPC_URL="https://rpc.supra.com"
        CHAIN_ID="999"
        ;;
    *)
        echo -e "${RED}Unknown network: $NETWORK${NC}"
        exit 1
        ;;
esac

echo "RPC URL: $RPC_URL"
echo "Chain ID: $CHAIN_ID"

# Check for private key
if [ -z "$SUPRA_PRIVATE_KEY" ]; then
    echo -e "${RED}Error: SUPRA_PRIVATE_KEY environment variable not set${NC}"
    echo "Please export your private key:"
    echo "  export SUPRA_PRIVATE_KEY=<your-private-key>"
    exit 1
fi

# Deploy using supra CLI
echo "Deploying contracts..."
$SUPRA_CLI publish \
    --rpc-url "$RPC_URL" \
    --chain-id "$CHAIN_ID" \
    --gas-budget 50000000 \
    --private-key "$SUPRA_PRIVATE_KEY"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Deployment successful!${NC}"
else
    echo -e "${RED}✗ Deployment failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}=== Deployment Complete ===${NC}"
echo "Check Supra Explorer: https://$([ "$NETWORK" = "testnet" ] && echo "testnet.")suprascan.io"
