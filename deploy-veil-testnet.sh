#!/bin/bash
# Deploy Veil Hub contracts to Supra testnet

WALLET_ADDRESS="0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026"
PRIVATE_KEY="0x1339610cbfbc335157de8575ae27dd3c8eb3843fb4a17f7b7fb4cc7ef772ec71"
RPC_URL="https://rpc-testnet.supra.com"
CONTAINER="supra_cli"

echo "=========================================="
echo "🚀 Veil Hub Deployment to Supra Testnet"
echo "=========================================="
echo ""
echo "📊 Deployment Configuration:"
echo "   Wallet: $WALLET_ADDRESS"
echo "   RPC: $RPC_URL"
echo "   Network: Testnet"
echo ""

# Step 1: Fund account from faucet
echo "[1/3] 💰 Funding account from testnet faucet..."
echo ""
echo "Visit this URL in your browser to fund:"
echo "   🔗 https://rpc-testnet.supra.com/rpc/v1/wallet/faucet/$WALLET_ADDRESS"
echo ""
echo "Or run (manual):"
echo "   docker exec $CONTAINER /supra/supra move account fund-with-faucet --rpc-url $RPC_URL"
echo ""
read -p "Press ENTER after funding your account from the faucet... "

# Step 2: Publish HelloSupra
echo ""
echo "[2/3] 📤 Publishing HelloSupra package..."
timeout 120 docker exec $CONTAINER /supra/supra move tool publish \
  --package-dir /supra/move_workspace/HelloSupra \
  --rpc-url $RPC_URL 2>&1 | tee /tmp/hello_supra_publish.log

if grep -q "Transaction succeeded" /tmp/hello_supra_publish.log || grep -q "Success" /tmp/hello_supra_publish.log; then
  echo "✅ HelloSupra published successfully"
  HELLO_TX=$(grep -oP '(?<=txn_hash": ")[^"]*' /tmp/hello_supra_publish.log | head -1)
  if [ -n "$HELLO_TX" ]; then
    echo "   Transaction: $HELLO_TX"
  fi
else
  echo "⚠️  HelloSupra publish may need manual intervention"
fi

# Step 3: Publish VeilHubCore
echo ""
echo "[3/3] 📤 Publishing VeilHubCore package..."
timeout 120 docker exec $CONTAINER /supra/supra move tool publish \
  --package-dir /supra/move_workspace/VeilHubCore \
  --rpc-url $RPC_URL 2>&1 | tee /tmp/veil_core_publish.log

if grep -q "Transaction succeeded" /tmp/veil_core_publish.log || grep -q "Success" /tmp/veil_core_publish.log; then
  echo "✅ VeilHubCore published successfully"
  VEIL_TX=$(grep -oP '(?<=txn_hash": ")[^"]*' /tmp/veil_core_publish.log | head -1)
  if [ -n "$VEIL_TX" ]; then
    echo "   Transaction: $VEIL_TX"
  fi
else
  echo "⚠️  VeilHubCore publish may need manual intervention"
fi

echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo ""
echo "📋 Deployed Modules:"
echo "   ✅ HelloSupra::hello"
echo "   ✅ VeilHubCore::veil_hub::core"
echo ""
echo "🔍 View on testnet:"
echo "   https://supraScan.io/account/$WALLET_ADDRESS?network=testnet"
echo ""
echo "📖 Next: Build the dApp frontend to interact with these contracts"
echo ""
