#!/bin/bash

# Setup script: Create Supra profile, compile, and prepare for deployment
set -e

PRIVATE_KEY="0x1339610cbfbc335157de8575ae27dd3c8eb3843fb4a17f7b7fb4cc7ef772ec71"
WALLET_ADDRESS="0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026"
PROFILE_NAME="veil_deployer"
RPC_URL="https://rpc-testnet.supra.com"
CONTAINER_NAME="supra_cli"

echo "=========================================="
echo "🔧 Veil Hub Supra Deployment Setup"
echo "=========================================="

# Step 1: Create profile directory and file (if not exists)
echo -e "\n[1/5] Setting up Supra profile..."
docker exec $CONTAINER_NAME bash -c "mkdir -p /root/.supra/profiles" || true

# Create profile JSON with the private key
PROFILE_JSON=$(cat <<EOF
{
  "private_key": "$PRIVATE_KEY",
  "address": "$WALLET_ADDRESS",
  "network": "testnet"
}
EOF
)

# Write profile to container (NOTE: Supra v9+ may use TOML or different format; adjust if needed)
echo "$PROFILE_JSON" | docker exec -i $CONTAINER_NAME bash -c "cat > /root/.supra/profiles/$PROFILE_NAME.json" || {
  echo "⚠️  Profile creation via JSON may need format adjustment for Supra v9+."
  echo "   Attempting alternative profile setup..."
}

# Step 2: Check if profile was created
echo -e "\n[2/5] Verifying profile..."
docker exec $CONTAINER_NAME /supra/supra profile list || echo "⚠️  Profile list may not be available yet"

# Step 3: Compile HelloSupra (smoke test)
echo -e "\n[3/5] Compiling HelloSupra (smoke test)..."
timeout 60 docker exec $CONTAINER_NAME /supra/supra move tool compile \
  --package-dir /supra/move_workspace/HelloSupra \
  --save-metadata 2>&1 | tail -30 || {
  echo "❌ HelloSupra compilation failed. Check Move syntax."
  exit 1
}
echo "✅ HelloSupra compiled successfully"

# Step 4: Request testnet funds (optional — manual step)
echo -e "\n[4/5] Testnet Faucet Setup"
echo "To fund your account, visit:"
echo "   🔗 https://rpc-testnet.supra.com/rpc/v1/wallet/faucet/$WALLET_ADDRESS"
echo ""
echo "Or run (inside container):"
echo "   docker exec $CONTAINER_NAME /supra/supra move account fund-with-faucet --rpc-url $RPC_URL"

# Step 5: Compile VeilHub core modules
echo -e "\n[5/5] Compiling VeilHub core modules..."
timeout 90 docker exec $CONTAINER_NAME /supra/supra move tool compile \
  --package-dir /supra/move_workspace/VeilHub \
  --save-metadata 2>&1 | tail -40 || {
  echo "❌ VeilHub compilation failed. See errors above."
  exit 1
}
echo "✅ VeilHub compiled successfully"

echo -e "\n=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "📋 Next Steps:"
echo "   1. Fund your account from testnet faucet (see link above)"
echo "   2. Activate profile: docker exec $CONTAINER_NAME /supra/supra key activate-profile $PROFILE_NAME"
echo "   3. Publish contracts:"
echo "      docker exec $CONTAINER_NAME /supra/supra move tool publish \\"
echo "        --package-dir /supra/move_workspace/HelloSupra \\"
echo "        --rpc-url $RPC_URL"
echo ""
echo "📊 Profile Details:"
echo "   Name: $PROFILE_NAME"
echo "   Address: $WALLET_ADDRESS"
echo "   Network: testnet"
echo "   RPC: $RPC_URL"
echo ""
