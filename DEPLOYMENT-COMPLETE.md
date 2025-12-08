# Veil Hub - Professional Deployment Guide

> **Status**: Production Ready ✅  
> **Version**: 2.0  
> **Last Updated**: December 8, 2025

## 🎯 Quick Start (5 Minutes)

```bash
# 1. Clone to your repository
git clone https://github.com/Thabiiey411beta/veil_hub.git
cd veil_hub

# 2. Setup frontend
cd veil-hub-v2
npm ci
npm run build

# 3. Deploy to Vercel
npm run deploy

# 4. Setup contracts (when ready)
cd ../scripts
./deploy-contracts.sh
```

---

## 📋 Full Deployment Checklist

### Phase 1: Preparation ✅ (Completed)

- [x] Vercel configuration created
- [x] Environment variables templated
- [x] GitHub Actions CI/CD setup
- [x] Move contracts ready for deployment
- [x] Frontend production build tested

### Phase 2: GitHub Setup (10 minutes)

- [ ] Push code to https://github.com/Thabiiey411beta/veil_hub
- [ ] Verify all commits in GitHub
- [ ] Check GitHub Actions workflows active

### Phase 3: Vercel Deployment (10 minutes)

- [ ] Import project to Vercel
- [ ] Set environment variables
- [ ] Trigger initial deploy
- [ ] Verify frontend loads

### Phase 4: Smart Contracts (30-45 minutes)

- [ ] Initialize Supra wallet
- [ ] Get testnet tokens
- [ ] Build contracts: `supra move build`
- [ ] Deploy contracts: `supra move publish --network testnet`
- [ ] Get contract addresses
- [ ] Update .env.local

### Phase 5: Integration Testing (15-20 minutes)

- [ ] Connect wallet in frontend
- [ ] Verify contract calls work
- [ ] Test all UI pages
- [ ] Check analytics data
- [ ] Validate transactions

### Phase 6: Production Ready (5 minutes)

- [ ] Final Vercel deploy with contract addresses
- [ ] DNS/domain setup (if using custom domain)
- [ ] Monitor application
- [ ] Setup error tracking

---

## 🚀 Deployment Methods

### Method 1: Vercel Dashboard (Easiest)

```
1. Visit https://vercel.com/dashboard
2. Click "Add New..." → "Project"
3. Select "Import Git Repository"
4. Paste: https://github.com/Thabiiey411beta/veil_hub
5. Select root: ./veil-hub-v2
6. Set environment variables (see below)
7. Click "Deploy"
```

### Method 2: GitHub Actions (Automatic)

```bash
# Push to GitHub
git push origin main

# Actions automatically:
# 1. Builds and tests contracts
# 2. Builds frontend
# 3. Deploys to Vercel (if secrets configured)
```

**Note**: Requires `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` in GitHub secrets.

### Method 3: CLI Deploy

```bash
cd veil-hub-v2

# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod

# Or use script
./deploy.sh
```

---

## 🔐 Environment Variables

### Vercel Dashboard Setup

Add these in **Vercel Dashboard → Settings → Environment Variables**:

```
NEXT_PUBLIC_SUPRA_TESTNET_RPC=https://rpc-testnet.supra.com
NEXT_PUBLIC_SUPRA_TESTNET_CHAIN_ID=6
NEXT_PUBLIC_SUPRA_TESTNET_FAUCET=https://rpc-testnet.supra.com/rpc/v1/wallet/faucet

NEXT_PUBLIC_SUPRA_MAINNET_RPC=https://rpc-mainnet.supra.com
NEXT_PUBLIC_SUPRA_MAINNET_CHAIN_ID=8

# After contract deployment:
NEXT_PUBLIC_VEIL_TOKEN_ADDRESS=0x<ADDRESS>::veil_token
NEXT_PUBLIC_AMM_ADDRESS=0x<ADDRESS>::amm
NEXT_PUBLIC_FARMING_ADDRESS=0x<ADDRESS>::farming
NEXT_PUBLIC_VEVEIL_ADDRESS=0x<ADDRESS>::veveil
```

### Local Development (.env.local)

Create `veil-hub-v2/.env.local`:

```bash
# Copy from template
cp veil-hub-v2/.env.template veil-hub-v2/.env.local

# Update with actual values after contract deployment
```

---

## 🔗 Smart Contract Deployment

### Prerequisites

```bash
# 1. Install Supra CLI
curl -fsSL https://cli.supra.ai | bash

# 2. Verify installation
supra --version

# 3. Initialize wallet
supra init

# 4. Get testnet tokens
# Visit: https://rpc-testnet.supra.com/rpc/v1/wallet/faucet/<YOUR_ADDRESS>
```

### Deployment Steps

```bash
# Navigate to contracts
cd supra/veil_testnet

# Build contracts
supra move build

# Deploy to testnet
supra move publish --network testnet

# Save output - contains deployed contract addresses!
# Example output:
# ✓ Package ID: 0xabcd1234...
# ✓ Modules: veil_token, amm, farming, veveil, burn_controller, debt_engine, immortal_reserve
```

### Get Contract Addresses

```bash
# List deployed modules
supra client list-modules --account $(supra config show | grep active_account)

# Or from deployment output above
```

---

## 📊 Project Structure

```
veil_hub/
├── veil-hub-v2/                    # Next.js Frontend
│   ├── app/                        # App router pages
│   │   ├── page.tsx               # Dashboard
│   │   ├── pools/
│   │   ├── farm/
│   │   ├── bridge/
│   │   ├── analytics/
│   │   └── aggregator/
│   ├── components/                 # React components
│   ├── hooks/                      # Custom hooks
│   ├── lib/                        # Utilities
│   ├── config/                     # Configuration files
│   ├── .env.template              # Environment template
│   ├── package.json
│   ├── tsconfig.json
│   ├── tailwind.config.ts
│   ├── next.config.js
│   ├── vercel.json                # Vercel config
│   └── deploy.sh                  # Deployment script
│
├── supra/                          # Smart Contracts
│   └── veil_testnet/
│       ├── sources/               # Move source files
│       │   ├── veil_coin.move
│       │   ├── amm.move
│       │   ├── farming.move
│       │   ├── veveil.move
│       │   ├── burn_controller.move
│       │   ├── debt_engine.move
│       │   └── immortal_reserve.move
│       └── Move.toml
│
├── scripts/                        # Deployment scripts
│   ├── deploy-contracts.sh        # Contract deployment
│   ├── verify-contracts.sh        # Verification
│   └── start-supra.sh             # Supra setup
│
├── .github/
│   └── workflows/
│       ├── deploy-vercel.yml      # Auto-deploy to Vercel
│       └── test-contracts.yml     # Contract testing
│
├── DEPLOYMENT.md                   # Vercel deployment guide
├── SMART_CONTRACT_DEPLOYMENT.md    # Contract deployment guide
├── INTEGRATION_TESTING.md          # Testing documentation
└── README.md                       # This file
```

---

## 🧪 Testing Before Deployment

### Local Testing

```bash
cd veil-hub-v2

# Install dependencies
npm ci

# Build for production
npm run build

# Start dev server
npm run dev

# Visit http://localhost:3000
```

### Contract Testing

```bash
cd supra/veil_testnet

# Run unit tests
supra move test

# Build for deployment
supra move build
```

### Network Verification

```bash
# Run verification script
./scripts/verify-contracts.sh

# Or manual check
curl -s https://rpc-testnet.supra.com/health | jq .
```

---

## 📈 Post-Deployment Verification

### 1. Check Frontend

```bash
# Visit deployed URL
https://veil-hub.vercel.app

# Verify pages load:
# - Dashboard ✓
# - Pools ✓
# - Farm ✓
# - Bridge ✓
# - Analytics ✓
# - Aggregator ✓
```

### 2. Check Contracts

```bash
# List deployed modules
supra client list-modules --account <YOUR_ADDRESS>

# Verify network
curl https://rpc-testnet.supra.com/health | jq .

# Check contract interactions work in frontend
```

### 3. Monitor Performance

```
Vercel Dashboard:
- Check deployment status
- Monitor performance metrics
- Review error logs
- Check analytics
```

---

## 🔧 Troubleshooting

### Frontend Build Issues

| Error | Solution |
|-------|----------|
| `Module not found` | `npm ci` to reinstall dependencies |
| `TypeScript error` | `npm run type-check` to identify issues |
| `Port already in use` | Kill process: `lsof -ti:3000 \| xargs kill` |
| `Vercel deployment fails` | Check env vars, build logs in Vercel dashboard |

### Contract Deployment Issues

| Error | Solution |
|-------|----------|
| `Supra CLI not found` | `curl -fsSL https://cli.supra.ai \| bash` |
| `Insufficient funds` | Get testnet tokens at faucet |
| `Network unreachable` | Check RPC: `curl https://rpc-testnet.supra.com/health` |
| `Module already published` | Redeploy to different package address |

### Wallet Connection Issues

| Error | Solution |
|-------|----------|
| `Wallet not detected` | Install Supra wallet extension |
| `Chain ID mismatch` | Verify `NEXT_PUBLIC_SUPRA_*_CHAIN_ID` in .env |
| `RPC error` | Check `NEXT_PUBLIC_SUPRA_*_RPC` endpoint |
| `Contract not found` | Verify contract address in .env |

---

## 📚 Documentation

- **[DEPLOYMENT.md](./veil-hub-v2/DEPLOYMENT.md)** - Detailed Vercel setup
- **[SMART_CONTRACT_DEPLOYMENT.md](./SMART_CONTRACT_DEPLOYMENT.md)** - Contract deployment guide
- **[INTEGRATION_TESTING.md](./INTEGRATION_TESTING.md)** - Testing strategy
- **[Supra Docs](https://docs.supra.com)** - Official Supra documentation

---

## 🚀 Deployment Timeline

| Phase | Time | Status |
|-------|------|--------|
| Setup (Vercel + env) | 10 min | ✅ Done |
| Frontend build | 5 min | ✅ Done |
| GitHub push | 5 min | ⏳ Ready |
| Vercel deploy | 10 min | ⏳ Ready |
| Contract deployment | 30 min | ⏳ Ready |
| Integration testing | 15 min | ⏳ Ready |
| **Total** | **75 min** | **⏳ Ready to start** |

---

## 💡 Best Practices

✅ **Do**
- Test locally before deploying
- Keep .env.local and secrets secure
- Monitor Vercel deployments
- Use GitHub for version control
- Document contract addresses
- Test contract interactions in dev
- Use testnet before mainnet

❌ **Don't**
- Commit .env.local to GitHub
- Use private keys in environment variables
- Skip testing before deployment
- Deploy to mainnet without thorough testing
- Hardcode contract addresses
- Use testnet RPC for production

---

## 📞 Support & Resources

- **Supra Discord**: https://discord.gg/supra
- **Supra Docs**: https://docs.supra.com
- **Vercel Docs**: https://vercel.com/docs
- **GitHub Issues**: Report issues in this repo

---

## 🎓 Learning Resources

- **Move Language**: https://move-language.github.io
- **Supra MoveVM**: https://docs.supra.com/supra-move-basics
- **Next.js**: https://nextjs.org/docs
- **wagmi**: https://wagmi.sh

---

## ✨ Success Criteria

After full deployment, verify:

- [ ] Frontend loads on https://veil-hub.vercel.app
- [ ] All 6 pages render without errors
- [ ] Wallet connection works
- [ ] Contract addresses in .env.local
- [ ] Contract calls succeed
- [ ] Analytics display data
- [ ] GitHub Actions pass
- [ ] No console errors in browser

**Once all criteria are met, deployment is complete! 🎉**

---

## 📄 License

MIT

---

**Questions?** Check documentation or open an issue on GitHub.

**Ready to deploy?** Start with Phase 2 above! 🚀
