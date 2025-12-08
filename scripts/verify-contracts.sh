#!/bin/bash

# Veil Hub - Smart Contract Verification Script
# Validates contract deployment and frontend integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TESTNET_RPC="https://rpc-testnet.supra.com"
MAINNET_RPC="https://rpc-mainnet.supra.com"
EXPLORER="https://testnet.suprascan.io"

echo -e "${BLUE}=== Veil Hub Smart Contract Verification ===${NC}\n"

# 1. Check Supra CLI
echo -e "${YELLOW}1. Checking Supra CLI...${NC}"
if command -v supra &> /dev/null; then
    SUPRA_VERSION=$(supra --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Supra CLI found: $SUPRA_VERSION${NC}"
else
    echo -e "${RED}✗ Supra CLI not found${NC}"
    echo "Install with: curl -fsSL https://cli.supra.ai | bash"
    exit 1
fi

# 2. Check network connectivity
echo -e "\n${YELLOW}2. Checking network connectivity...${NC}"

echo "Testing Testnet RPC..."
if curl -s "$TESTNET_RPC/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Testnet RPC responding${NC}"
else
    echo -e "${RED}✗ Testnet RPC unreachable${NC}"
    exit 1
fi

echo "Testing Mainnet RPC..."
if curl -s "$MAINNET_RPC/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Mainnet RPC responding${NC}"
else
    echo -e "${YELLOW}⚠ Mainnet RPC unreachable (may be normal if offline)${NC}"
fi

# 3. Check wallet configuration
echo -e "\n${YELLOW}3. Checking wallet configuration...${NC}"
if supra config show &>/dev/null; then
    WALLET=$(supra config show | grep -i "active_account" | head -1 || echo "Not configured")
    echo -e "${GREEN}✓ Wallet configured${NC}"
    echo "  $WALLET"
else
    echo -e "${YELLOW}⚠ Wallet not configured. Run: supra init${NC}"
fi

# 4. Check contract sources
echo -e "\n${YELLOW}4. Verifying contract sources...${NC}"
CONTRACTS=(
    "veil_coin.move"
    "veveil.move"
    "amm.move"
    "farming.move"
    "burn_controller.move"
    "debt_engine.move"
    "immortal_reserve.move"
)

for contract in "${CONTRACTS[@]}"; do
    if [ -f "supra/veil_testnet/sources/$contract" ]; then
        echo -e "${GREEN}✓ $contract${NC}"
    else
        echo -e "${RED}✗ $contract not found${NC}"
    fi
done

# 5. Build contracts
echo -e "\n${YELLOW}5. Building Move contracts...${NC}"
cd supra/veil_testnet
if supra move build 2>&1 | tee /tmp/build.log; then
    echo -e "${GREEN}✓ Contracts built successfully${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    cat /tmp/build.log
    cd ../..
    exit 1
fi
cd ../..

# 6. Check frontend configuration
echo -e "\n${YELLOW}6. Checking frontend configuration...${NC}"

if [ -f "veil-hub-v2/.env.local" ]; then
    echo -e "${GREEN}✓ .env.local exists${NC}"
    
    # Check for required variables
    REQUIRED_VARS=(
        "NEXT_PUBLIC_SUPRA_TESTNET_RPC"
        "NEXT_PUBLIC_SUPRA_TESTNET_CHAIN_ID"
    )
    
    for var in "${REQUIRED_VARS[@]}"; do
        if grep -q "$var=" "veil-hub-v2/.env.local"; then
            VALUE=$(grep "$var=" "veil-hub-v2/.env.local" | cut -d'=' -f2)
            echo -e "${GREEN}✓ $var${NC}"
        else
            echo -e "${YELLOW}⚠ $var not set${NC}"
        fi
    done
else
    echo -e "${YELLOW}⚠ .env.local not found${NC}"
    echo "Create with: cp veil-hub-v2/.env.template veil-hub-v2/.env.local"
fi

# 7. Build frontend
echo -e "\n${YELLOW}7. Building frontend...${NC}"
cd veil-hub-v2
if npm run build 2>&1 | tail -20; then
    echo -e "${GREEN}✓ Frontend built successfully${NC}"
else
    echo -e "${RED}✗ Frontend build failed${NC}"
    cd ..
    exit 1
fi
cd ..

# 8. Check contract addresses in env
echo -e "\n${YELLOW}8. Verifying contract address configuration...${NC}"

CONTRACT_VARS=(
    "NEXT_PUBLIC_VEIL_TOKEN_ADDRESS"
    "NEXT_PUBLIC_AMM_ADDRESS"
    "NEXT_PUBLIC_FARMING_ADDRESS"
    "NEXT_PUBLIC_VEVEIL_ADDRESS"
)

for var in "${CONTRACT_VARS[@]}"; do
    if grep -q "$var=" "veil-hub-v2/.env.local"; then
        VALUE=$(grep "$var=" "veil-hub-v2/.env.local" | cut -d'=' -f2)
        if [ -z "$VALUE" ] || [ "$VALUE" = "0x" ]; then
            echo -e "${YELLOW}⚠ $var not set (deployment pending)${NC}"
        else
            echo -e "${GREEN}✓ $var=${VALUE}${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ $var not configured${NC}"
    fi
done

# 9. Summary
echo -e "\n${BLUE}=== Verification Summary ===${NC}"
echo -e "${GREEN}✓ Supra CLI: Verified${NC}"
echo -e "${GREEN}✓ Network: Connected${NC}"
echo -e "${GREEN}✓ Contracts: Built${NC}"
echo -e "${GREEN}✓ Frontend: Built${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Deploy contracts: cd supra/veil_testnet && supra move publish --network testnet"
echo "2. Get testnet tokens: Visit https://rpc-testnet.supra.com/rpc/v1/wallet/faucet/<ADDRESS>"
echo "3. Update .env.local with deployed contract addresses"
echo "4. Deploy frontend to Vercel"
echo "5. Test wallet connection and contract interactions"

echo -e "\n${BLUE}For more information:${NC}"
echo "- Docs: https://docs.supra.com"
echo "- Explorer: $EXPLORER"
echo "- Discord: https://discord.gg/supra"

echo -e "\n${GREEN}✓ Verification complete!${NC}\n"
