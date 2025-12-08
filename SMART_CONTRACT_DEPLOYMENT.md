# Veil Hub - Smart Contract Deployment & Testing Guide

## 🚀 Quick Start

### Prerequisites
```bash
# 1. Install Supra CLI
curl -fsSL https://cli.supra.ai | bash

# 2. Verify installation
supra --version

# 3. Initialize wallet
supra init
```

### 1. Deploy Smart Contracts

```bash
# Run deployment script
./scripts/deploy-contracts.sh

# Or manual deployment
cd supra/veil_testnet
supra move publish --network testnet
cd ../..
```

### 2. Get Testnet Tokens

After deployment, fund your account:
```bash
# Visit faucet
https://rpc-testnet.supra.com/rpc/v1/wallet/faucet/<YOUR_ADDRESS>

# Or use curl
curl -X POST "https://rpc-testnet.supra.com/rpc/v1/wallet/faucet" \
  -H "Content-Type: application/json" \
  -d '{
    "address": "0x<YOUR_ADDRESS>"
  }'
```

### 3. Verify Deployment

After contracts are deployed, get their addresses:

```bash
# List deployed modules
supra move list --network testnet --account <ACCOUNT_ADDRESS>
```

### 4. Update Frontend Configuration

Copy contract addresses to `veil-hub-v2/.env.local`:

```env
# Supra Testnet
NEXT_PUBLIC_SUPRA_TESTNET_RPC=https://rpc-testnet.supra.com
NEXT_PUBLIC_SUPRA_TESTNET_CHAIN_ID=6
NEXT_PUBLIC_SUPRA_TESTNET_FAUCET=https://rpc-testnet.supra.com/rpc/v1/wallet/faucet

# Contract Addresses (from deployment)
NEXT_PUBLIC_VEIL_TOKEN_ADDRESS=0x<DEPLOYED_ADDRESS>::veil_token
NEXT_PUBLIC_AMM_ADDRESS=0x<DEPLOYED_ADDRESS>::amm
NEXT_PUBLIC_FARMING_ADDRESS=0x<DEPLOYED_ADDRESS>::farming
NEXT_PUBLIC_VEVEIL_ADDRESS=0x<DEPLOYED_ADDRESS>::veveil
```

---

## 🧪 Testing & Validation

### Unit Tests (Smart Contracts)

```bash
# Build with tests
cd supra/veil_testnet
supra move test

# Run specific test
supra move test amm::tests
```

### Frontend Tests

```bash
cd veil-hub-v2

# Run Next.js build
npm run build

# Start dev server
npm run dev
```

Visit http://localhost:3000 and test:
- [ ] Dashboard loads
- [ ] Wallet connects
- [ ] Can view pools
- [ ] Analytics populate
- [ ] Bridge UI renders
- [ ] Aggregator loads strategies

### Integration Tests

```bash
# Test wallet connection to testnet
curl -X POST "https://rpc-testnet.supra.com" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "sui_getChainIdentifier",
    "params": [],
    "id": 1
  }'

# Expected response: chain_id = 6
```

---

## 📋 Smart Contracts Overview

### 1. **veil_coin.move** - VEIL Token
- Fungible asset standard implementation
- Mint/burn mechanisms
- Transfer controls

### 2. **veveil.move** - Governance Token
- Vote-escrowed VEIL
- Escrow lock period
- Governance rights

### 3. **amm.move** - Automated Market Maker
- Liquidity pools
- Swap functionality
- Fee collection

### 4. **farming.move** - Yield Farming
- Staking mechanisms
- Reward distribution
- APY calculations

### 5. **burn_controller.move** - Token Burning
- Burn mechanism control
- Supply management

### 6. **debt_engine.move** - Lending Protocol
- Collateralization tracking
- Interest calculation
- Liquidation logic

### 7. **immortal_reserve.move** - Protocol Reserve
- Treasury management
- Distribution mechanism

---

## ✅ Deployment Checklist

- [ ] Supra CLI installed and initialized
- [ ] Testnet tokens acquired
- [ ] All contracts build without errors
- [ ] Contracts deployed to testnet
- [ ] Contract addresses verified on explorer
- [ ] Environment variables updated in frontend
- [ ] Frontend builds successfully
- [ ] Wallet connection tested
- [ ] Contract interactions tested
- [ ] All UI pages load correctly
- [ ] Analytics display data
- [ ] Deployed to Vercel

---

## 🌐 Network Information

**Supra Testnet:**
- RPC: https://rpc-testnet.supra.com
- Chain ID: 6
- Explorer: https://testnet.suprascan.io
- Faucet: https://rpc-testnet.supra.com/rpc/v1/wallet/faucet

**Supra Mainnet:**
- RPC: https://rpc-mainnet.supra.com
- Chain ID: 8
- Explorer: https://explorer.supra.com

---

## 🔗 Verification Commands

```bash
# Check network status
curl -s https://rpc-testnet.supra.com/health | jq .

# Check chain identifier
curl -X POST https://rpc-testnet.supra.com \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"sui_getChainIdentifier","params":[],"id":1}' | jq .

# Get account balance
supra client balance --address <ADDRESS> --rpc https://rpc-testnet.supra.com

# List transactions
supra client tx-list --address <ADDRESS> --rpc https://rpc-testnet.supra.com
```

---

## 📚 Useful Resources

- **Supra Docs**: https://docs.supra.com
- **Move Language**: https://move-language.github.io
- **Explorer**: https://testnet.suprascan.io
- **Supra CLI**: https://cli.supra.ai

---

## 🐛 Troubleshooting

### "Supra CLI not found"
```bash
curl -fsSL https://cli.supra.ai | bash
source ~/.bashrc  # Reload shell
```

### "Insufficient funds"
Request testnet tokens at: https://rpc-testnet.supra.com/rpc/v1/wallet/faucet/YOUR_ADDRESS

### "Contract deployment failed"
- Check CLI wallet is initialized: `supra config show`
- Ensure account has testnet tokens
- Verify network connectivity: `curl -s https://rpc-testnet.supra.com/health`

### "Frontend can't connect to contracts"
- Verify contract addresses in `.env.local`
- Check RPC endpoint is responding
- Clear browser cache and restart dev server

---

## 📞 Support

- **Supra Community**: https://discord.gg/supra
- **Issues**: GitHub Issues
- **Documentation**: https://docs.supra.com

---

**Last Updated**: December 8, 2025  
**Status**: Production Ready ✓
