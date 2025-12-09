# ⚡ Quick Deploy Steps (Manual)

Since SSH keys aren't configured in this environment, here are the **exact manual steps** you need to run locally to complete the deployment.

## Prerequisites

- Local git configured with GitHub credentials or a Personal Access Token (PAT)
- Local Docker installed (for contract deployment)
- The `/path/to/veil_hub` repo cloned locally

## Step 1: Create veil_hub2 Repository (GitHub Web)

1. Go to https://github.com/new
2. Fill in:
   - **Repository name**: `veil_hub2`
   - **Owner**: `Thabiiey411beta`
   - **Visibility**: Public
   - **Initialize with README**: Yes
3. Click **Create repository**
4. Copy the HTTPS URL: `https://github.com/Thabiiey411beta/veil_hub2.git`

## Step 2: Push Frontend to veil_hub2 (Local Machine)

Run these commands **on your local machine**:

```bash
# Navigate to frontend
cd /path/to/veil_hub/veil-hub-v2

# Change remote to veil_hub2
git remote set-url origin https://github.com/Thabiiey411beta/veil_hub2.git

# Push frontend
git push -u origin main
```

When prompted:
- **Username**: Your GitHub username
- **Password**: Your Personal Access Token (if using 2FA) or GitHub password

**Generate a Personal Access Token** if needed:
1. Go to https://github.com/settings/tokens/new
2. Name: `veil-deployment`
3. Expiration: 90 days
4. Scopes: Check ✓ `repo`
5. Click **Generate token**
6. Copy the token immediately (won't show again)

## Step 3: Connect veil_hub2 to Vercel

1. Go to https://vercel.com/dashboard
2. Click **Add New** → **Project**
3. Click **Import Git Repository**
4. Paste: `https://github.com/Thabiiey411beta/veil_hub2`
5. Click **Continue** and authorize Vercel
6. Select the `veil_hub2` repository
7. Configure:
   - **Project Name**: `veil-hub-frontend` (or your choice)
   - **Framework**: Next.js (auto-selected)
   - **Root Directory**: `./`
8. Click **Deploy**

(It may fail due to missing env vars — that's OK, we'll add them next)

## Step 4: Add Environment Variables in Vercel

In your Vercel project:

1. Go to **Settings** → **Environment Variables**
2. Add each variable one at a time:

### Supra RPC Endpoints
```
NEXT_PUBLIC_SUPRA_MAINNET_RPC = https://rpc-mainnet.supra.com
NEXT_PUBLIC_SUPRA_TESTNET_RPC = https://rpc-testnet.supra.com
NEXT_PUBLIC_SUPRA_MAINNET_CHAIN_ID = 999
NEXT_PUBLIC_SUPRA_TESTNET_CHAIN_ID = 6
NEXT_PUBLIC_SUPRA_TESTNET_FAUCET = https://rpc-testnet.supra.com/rpc/v1/wallet/faucet
```

### Testnet Contract Addresses
```
NEXT_PUBLIC_VEIL_TOKEN_TESTNET = 0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026::veil_token
NEXT_PUBLIC_YIELD_OPTIMIZER_TESTNET = 0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026::yield_optimizer
NEXT_PUBLIC_AI_GOVERNANCE_TESTNET = 0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026::ai_governance
NEXT_PUBLIC_IASSETS_VAULT_TESTNET = 0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026::iassets_vault
NEXT_PUBLIC_AMM_TESTNET = 0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026::amm
NEXT_PUBLIC_FARMING_TESTNET = 0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026::farming
NEXT_PUBLIC_IMMORTAL_RESERVE_TESTNET = 0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026::immortal_reserve
```

### Mainnet Contract Addresses (Leave Empty for Now)
```
NEXT_PUBLIC_VEIL_TOKEN_MAINNET = [leave empty]
NEXT_PUBLIC_YIELD_OPTIMIZER_MAINNET = [leave empty]
NEXT_PUBLIC_AI_GOVERNANCE_MAINNET = [leave empty]
NEXT_PUBLIC_IASSETS_VAULT_MAINNET = [leave empty]
NEXT_PUBLIC_AMM_MAINNET = [leave empty]
NEXT_PUBLIC_FARMING_MAINNET = [leave empty]
NEXT_PUBLIC_IMMORTAL_RESERVE_MAINNET = [leave empty]
```

3. After adding all variables, go to **Deployments**
4. Click **Redeploy** on the failed build
5. Watch the build log — should succeed now
6. Click the preview URL when done

## Step 5: Test Your Live Frontend

1. Visit the Vercel deployment URL (e.g., `https://veil-hub-frontend.vercel.app`)
2. Test each page:
   - `/` — Home
   - `/dashboard` — Portfolio
   - `/bridge` — Cross-chain bridge
   - `/pools` — Liquidity pools
   - `/farm` — Farming
   - `/aggregator` — Yield aggregator
   - `/analytics` — Protocol analytics
3. Open browser console (F12) — should have no errors
4. Try connecting a Supra wallet (if available)

## Step 6: Deploy Contracts (Optional — Do Anytime)

From your local machine, deploy contracts to Supra testnet:

```bash
cd /path/to/veil_hub

# Start Supra CLI container
./scripts/setup-supra-cli.sh

# Initialize your account (generates new keypair and requests testnet funds)
./scripts/init-supra-account.sh accountA testnet

# Enter the container shell
./scripts/enter-supra-cli.sh

# Inside container: Compile contracts
supra move tool compile --package-dir /supra/move_workspace/exampleContract

# Inside container: Publish to testnet
supra move tool publish --package-dir /supra/move_workspace/exampleContract --rpc-url https://rpc-testnet.supra.com
```

After publishing:
1. Copy the module address from Supra testnet explorer (https://testnet.suprascan.io)
2. Update the corresponding contract address in Vercel env vars
3. Redeploy frontend in Vercel

## That's It! 🚀

Your application is now deployed and ready to use.

**Summary of what you did:**
1. ✓ Pushed frontend to veil_hub2
2. ✓ Connected to Vercel for hosting
3. ✓ Added environment secrets for Supra RPCs
4. ✓ Deployed to production
5. ✓ (Optional) Deployed contracts to testnet

**Live Endpoints:**
- Frontend: `https://<your-vercel-domain>`
- Backend (when deployed): https://rpc-testnet.supra.com

**Support:**
- Frontend guide: `veil-hub-v2/FRONTEND_DEPLOYMENT_GUIDE.md`
- Backend guide: `QUICKSTART_DEPLOYMENT.md`
- CLI guide: `SUPRA_CLI_DOCKER.md`

