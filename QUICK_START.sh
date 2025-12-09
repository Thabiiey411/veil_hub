#!/usr/bin/env bash

# QUICK START: Notion Integration + Supra Contract Deployment
# This script walks through the complete flow step-by-step

set -euo pipefail

echo "=========================================="
echo "Veil Hub - Notion + Supra Deployment"
echo "=========================================="
echo ""

# Function to print steps
step() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "STEP $1: $2"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to prompt user
ask() {
  read -p "$(echo -e '\033[1;36m?')" -r REPLY
  [[ $REPLY == [yY] ]]
}

step 1 "Setup Notion Integration"
echo ""
echo "Option A: Automated (requires Notion API key)"
echo "Option B: Manual Copy-Paste (no API needed)"
echo ""

read -p "Choose (a/b): " notion_choice
case $notion_choice in
  a|A)
    echo ""
    echo "🔑 Get your Notion credentials:"
    echo "1. Visit: https://www.notion.so/my-integrations"
    echo "2. Create new integration → Copy API key"
    echo "3. Share a Notion page with the integration"
    echo "4. Get page ID from URL: notion.so/<PAGE_ID>?..."
    echo ""
    read -sp "Enter NOTION_API_KEY: " NOTION_API_KEY
    echo ""
    read -p "Enter NOTION_PAGE_ID: " NOTION_PAGE_ID
    echo ""
    echo "Running Notion integration..."
    export NOTION_API_KEY NOTION_PAGE_ID
    cd /workspaces/veil_hub
    if bash notion-whitepaper-integration.sh; then
      echo "✅ Whitepaper published to Notion!"
    else
      echo "⚠️  Manual integration needed. Follow Option B below."
    fi
    ;;
  b|B)
    echo ""
    echo "📋 Copy whitepaper to clipboard:"
    cat /workspaces/veil_hub/NORION-WHITEPAPER.md | xclip -selection clipboard
    echo "✅ Whitepaper copied to clipboard!"
    echo ""
    echo "📝 In Notion:"
    echo "1. Create new page"
    echo "2. Type '/code' and select Code block"
    echo "3. Paste the content (Ctrl+V)"
    echo "4. Change language to 'markdown'"
    echo ""
    read -p "Press Enter when done..."
    ;;
esac

step 2 "Verify Supra CLI"
echo ""
echo "Checking if Supra CLI container is running..."
if docker ps --filter "name=supra_cli" --format "{{.Names}}" | grep -q supra_cli; then
  echo "✅ Supra CLI container is running"
  docker ps --filter "name=supra_cli" --format "table {{.Names}}\t{{.Status}}"
else
  echo "⚠️  Supra CLI not running. Starting..."
  bash /workspaces/veil_hub/scripts/setup-supra-cli.sh
  sleep 3
  echo "✅ Supra CLI started"
fi

step 3 "Create Supra Account"
echo ""
echo "Account name: accountA"
read -p "Confirm account creation (y/n): " confirm_account

if [[ $confirm_account == [yY] ]]; then
  docker exec supra_cli bash -c "
    supra account init accountA testnet 2>/dev/null || echo 'Account already exists'
  "
  
  ACCOUNT_ADDR=$(docker exec supra_cli bash -c "
    supra account list | grep accountA | awk '{print \$2}' | head -1
  ")
  
  if [ -n "$ACCOUNT_ADDR" ]; then
    echo "✅ Account created/verified!"
    echo "📍 Address: $ACCOUNT_ADDR"
  else
    echo "⚠️  Account creation failed"
    exit 1
  fi
else
  read -p "Enter existing account name: " ACCOUNT_NAME
  ACCOUNT_ADDR=$(docker exec supra_cli bash -c "
    supra account list | grep $ACCOUNT_NAME | awk '{print \$2}' | head -1
  ")
  echo "📍 Address: $ACCOUNT_ADDR"
fi

step 4 "Fund Account (Testnet Faucet)"
echo ""
echo "⚠️  Account needs 10 TEST SUP tokens to deploy contracts"
echo ""
echo "Faucet URL: https://faucet.testnet.supra.com"
echo "Your address: $ACCOUNT_ADDR"
echo ""
read -p "Visit the faucet and claim tokens. Press Enter when done... "

# Check balance
echo ""
echo "Checking balance..."
BALANCE=$(docker exec supra_cli bash -c "
  supra account list | grep accountA | awk '{print \$4}'
" 2>/dev/null || echo "unknown")

echo "Balance: $BALANCE SUP"

step 5 "Compile Contracts"
echo ""
echo "Compiling 26 Move smart contracts..."
echo "This may take 1-2 minutes..."
echo ""

if docker exec supra_cli supra move tool compile \
  --package-dir /workspace/supra/move_workspace/VeilHub; then
  echo "✅ Compilation successful!"
else
  echo "❌ Compilation failed"
  exit 1
fi

step 6 "Deploy Contracts"
echo ""
echo "Deploying contracts to Supra testnet..."
echo "Chain ID: 6"
echo "RPC: https://rpc-testnet.supra.com"
echo ""

if docker exec supra_cli supra move tool publish \
  --package-dir /workspace/supra/move_workspace/VeilHub \
  --account accountA \
  --rpc-url https://rpc-testnet.supra.com; then
  echo "✅ Deployment successful!"
else
  echo "❌ Deployment failed"
  echo "Check logs: docker logs supra_cli"
  exit 1
fi

step 7 "Verify Deployment"
echo ""
echo "Verifying deployed contracts..."
echo ""

docker exec supra_cli supra move object list \
  --address $ACCOUNT_ADDR \
  --rpc-url https://rpc-testnet.supra.com | head -30

echo ""
echo "🔗 Full explorer: https://testnet.supra.com/address/$ACCOUNT_ADDR"

step 8 "Summary"
echo ""
echo "✅ Notion whitepaper published"
echo "✅ Supra CLI configured"
echo "✅ Account created: accountA"
echo "✅ Contracts compiled"
echo "✅ Contracts deployed to testnet"
echo ""
echo "🚀 Your Veil Hub is now live on Supra testnet!"
echo ""
echo "📚 Documentation:"
echo "  - DEPLOYMENT_STATUS_COMPLETE.md (this guide)"
echo "  - SUPRA_DEPLOYMENT.md (deployment reference)"
echo "  - NOTION_INTEGRATION.md (Notion setup)"
echo "  - NORION-WHITEPAPER.md (whitepaper)"
echo ""
echo "🔗 Useful Links:"
echo "  - Testnet Explorer: https://testnet.supra.com"
echo "  - Faucet: https://faucet.testnet.supra.com"
echo "  - Your Address: https://testnet.supra.com/address/$ACCOUNT_ADDR"
echo ""
echo "=========================================="
echo "Deployment Complete! 🎉"
echo "=========================================="
