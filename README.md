# 🌑 Veil Ecosystem - Supra L1

**Privacy-First DeFi Protocol | Unified Tokenomics | Built on Supra L1**

[![Supra L1](https://img.shields.io/badge/Supra-L1-blue)](https://supra.com)
[![Move](https://img.shields.io/badge/Language-Move-orange)](https://move-language.github.io/move/)
[![Modules](https://img.shields.io/badge/Modules-18-green)](./move/sourcesgit add README.md
git commit -m "Update README"
git push origin main
)
[![Status](https://img.shields.io/badge/Status-Ready%20to%20Deploy-success)](./DEPLOYMENT-COMPLETE.md)

## 🎯 Overview

**Veil Hub + Veil Finance + Phantom Indices** = Complete DeFi ecosystem powered by single $VEIL token.

### Key Metrics
- 💰 **$280.5M** annual revenue @ $3B TVL
- 📈 **49% APR** USDC dividends for holders
- 🔧 **18 Move modules** on Supra L1
- ⭐ **9.8/10** sustainability score
- 🔒 **100% supra_framework** (no aptos references)

## Architecture

```
$VEIL Token (1B supply)
    ↓
┌───┴────┬─────────┬──────────┐
│        │         │          │
Hub    Finance  Indices   Treasury
│        │         │          │
└────┬───┴─────────┴──────────┘
     ↓
Immortal Reserve
     ↓
USDC Dividends (49% APR)
```

## Modules (18 Total)

### Veil Hub (5)
- `veil_token` - 1B supply, 8 decimals
- `debt_engine` - Borrowing at 5.5% APR
- `immortal_reserve` - USDC dividends
- `buyback_engine` - VEIL buyback
- `veveil` - Governance token

### Veil Finance (6)
- `amm` - 0.3% fee AMM
- `router` - Multi-hop swaps
- `perpetual_dex` - 5 bps perp fees
- `farming` - LP staking
- `burn_controller` - Phase-based caps
- `shadow_gas` - Privacy fees

### Phantom Indices (3)
- `index_factory` - Create indices (10k VEIL)
- `stable_bundle` - Stable bundles (5k VEIL)
- `rebalancer` - Auto-rebalance

### Integrations (3)
- `supra_oracle` - Price feeds
- `supra_vrf` - Randomness
- `supra_autofi` - Automation

### Governance (1)
- `treasury` - Revenue tracking

## 🚀 Quick Start

### Deployment Options

#### Option 1: Web Console (Easiest - 10 minutes)
1. Visit https://console.supra.com
2. Connect wallet
3. Upload `/move` folder
4. Click "Deploy"

📖 **[Complete Guide](OPTION-1-WEB-CONSOLE-DEPLOYMENT.md)**

#### Option 2: Supra Team Support (Recommended - 3-5 days)
1. Email: developers@supra.com
2. Subject: "Veil Finance Deployment Request"
3. Include wallet: `0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026`
4. They deploy for you

📖 **[Complete Guide](OPTION-2-SUPRA-TEAM-DEPLOYMENT.md)**

#### Option 3: CLI (Advanced)
```bash
cd move
supra move publish \
  --package-dir . \
  --named-addresses veil_hub=YOUR_ADDRESS,veil_finance=YOUR_ADDRESS,phantom_indices=YOUR_ADDRESS \
  --url https://rpc-testnet.supra.com \
  --private-key YOUR_KEY
```

📖 **[Complete Guide](DEPLOYMENT-SUPRA.md)**

## Documentation

- [UNIFIED-TOKENOMICS-V17.md](UNIFIED-TOKENOMICS-V17.md) - Complete tokenomics
- [PHASE-2-ROADMAP.md](PHASE-2-ROADMAP.md) - Phase 2 features (Q3 2026)
- [VEIL-V17-PHANTOM-INDICES.md](VEIL-V17-PHANTOM-INDICES.md) - Indices mechanics
- [VEIL-V17-SUSTAINABLE-ECOSYSTEM.md](VEIL-V17-SUSTAINABLE-ECOSYSTEM.md) - Sustainability model
- [VEIL-V17-ALL-WEATHER-PROFITS.md](VEIL-V17-ALL-WEATHER-PROFITS.md) - Profit strategy
- [VEIL-V17-SECURITY-HARDENED.md](VEIL-V17-SECURITY-HARDENED.md) - Security guide
- [DEPLOYMENT-SUPRA.md](DEPLOYMENT-SUPRA.md) - Deployment guide
- [MANUAL-DEPLOYMENT-STEPS.md](MANUAL-DEPLOYMENT-STEPS.md) - Manual steps

## Tokenomics

- **Max Supply**: 1B VEIL
- **Reserve Floor**: 100M (10% never burned)
- **Burn Phases**: 30% → 20% → 10% annually
- **Final Supply**: 100-120M (10-12%)

### Revenue Splits
- 35% → Immortal Reserve (USDC dividends)
- 50% → Burns (capped)
- 10% → veVEIL stakers
- 5% → Treasury

### Holder Returns
- **Base Case**: 49% APR @ $3B TVL
- **Bear Market**: 33% APR minimum
- **Bull Market**: 82% APR @ $5B TVL

## 🗺️ Roadmap

### Phase 1 (Q1 2026) - Core Launch ✅
- **18 Modules**: Hub (5) + Finance (6) + Indices (3) + Integrations (3) + Governance (1)
- **Revenue**: $280.5M annually @ $3B TVL
- **APR**: 49% USDC dividends
- **Status**: Ready for deployment

### Phase 2 (Q3 2026) - Enhanced Features 🚀
- **+3 Modules**: LP Vacuum + Enhanced veVEIL + Protocol-Owned Liquidity
- **Revenue**: $329M annually (+17% boost)
- **APR**: 55% USDC dividends (+6% boost)
- **Features**: Permanent liquidity, boosted yields, protocol ownership

📖 **[Phase 2 Details](PHASE-2-ROADMAP.md)**

**Why Phase 2?** Deploy core first, validate with users, iterate based on feedback. Faster launch, lower audit costs, better market timing.

## Network Details

### Testnet
- **RPC**: https://rpc-testnet.supra.com
- **Chain ID**: 9999
- **Explorer**: https://testnet.suprascan.io

### Mainnet
- **RPC**: https://rpc-mainnet.supra.com
- **Chain ID**: 6
- **Explorer**: https://suprascan.io

## 📊 Project Status

### ✅ Completed
- [x] 18 Move modules implemented
- [x] 100% supra_framework (no aptos)
- [x] Documentation complete (2,500+ lines)
- [x] Tokenomics unified v17
- [x] Security hardening documented
- [x] All-weather profit model
- [x] Deployment guides created
- [x] Credentials configured

### ⏳ Pending
- [ ] Deploy to Supra testnet
- [ ] Initialize all 18 modules
- [ ] Run integration tests
- [ ] Connect frontend
- [ ] Audits (Q2 2026)
- [ ] Mainnet launch

### 🎯 Ready For
- ✅ Immediate testnet deployment
- ✅ Supra team review
- ✅ Web console upload
- ✅ CLI deployment (if available)

## 📚 Documentation

### Core Docs
- [README.md](README.md) - This file
- [UNIFIED-TOKENOMICS-V17.md](UNIFIED-TOKENOMICS-V17.md) - Complete tokenomics (340 lines)
- [DEPLOYMENT-COMPLETE.md](DEPLOYMENT-COMPLETE.md) - Deployment status
- [FINAL-STATUS.md](FINAL-STATUS.md) - Project completion summary

### Deployment Guides
- [OPTION-1-WEB-CONSOLE-DEPLOYMENT.md](OPTION-1-WEB-CONSOLE-DEPLOYMENT.md) - Web console (easiest)
- [OPTION-2-SUPRA-TEAM-DEPLOYMENT.md](OPTION-2-SUPRA-TEAM-DEPLOYMENT.md) - Team support
- [DEPLOYMENT-SUPRA.md](DEPLOYMENT-SUPRA.md) - CLI deployment
- [DEPLOY-NOW.md](DEPLOY-NOW.md) - Quick start

### Technical Docs
- [PHASE-2-ROADMAP.md](PHASE-2-ROADMAP.md) - Phase 2 features (Q3 2026)
- [VEIL-V17-PHANTOM-INDICES.md](VEIL-V17-PHANTOM-INDICES.md) - Indices mechanics (92 lines)
- [VEIL-V17-SUSTAINABLE-ECOSYSTEM.md](VEIL-V17-SUSTAINABLE-ECOSYSTEM.md) - Sustainability (320 lines)
- [VEIL-V17-ALL-WEATHER-PROFITS.md](VEIL-V17-ALL-WEATHER-PROFITS.md) - Profit strategy (332 lines)
- [VEIL-V17-SECURITY-HARDENED.md](VEIL-V17-SECURITY-HARDENED.md) - Security guide (612 lines)
- [ANALYSIS-ERRORS-FIXES.md](ANALYSIS-ERRORS-FIXES.md) - Error analysis (376 lines)

## 🛠️ Development

### Project Structure
```
veil-hub-v2/
├── move/                    # Move modules
│   ├── Move.toml           # Package config
│   └── sources/
│       ├── veil_hub/       # 5 modules (lending)
│       ├── veil_finance/   # 6 modules (trading)
│       ├── phantom_indices/# 3 modules (indices)
│       ├── integrations/   # 3 modules (Supra)
│       └── governance/     # 1 module (treasury)
├── app/                    # Next.js frontend
├── components/             # React components
├── lib/                    # SDK integrations
└── docs/                   # Documentation
```

### Tech Stack
- **Blockchain**: Supra L1 (Move language)
- **Framework**: supra_framework
- **Frontend**: Next.js + React
- **SDK**: supra-l1-sdk v4.3.1
- **Oracles**: Supra DORA
- **Automation**: Supra AutoFi

## 🔗 Links

### Supra Network
- **Testnet RPC**: https://rpc-testnet.supra.com
- **Testnet Explorer**: https://testnet.suprascan.io
- **Mainnet RPC**: https://rpc-mainnet.supra.com
- **Mainnet Explorer**: https://suprascan.io
- **Faucet**: https://faucet.supra.com
- **Console**: https://console.supra.com

### Veil Finance
- **Wallet**: `0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026`
- **GitHub**: [Your repo]
- **Docs**: https://docs.veil.finance
- **Discord**: https://discord.gg/veil

### Supra Support
- **Email**: developers@supra.com
- **Discord**: https://discord.gg/supra
- **Telegram**: https://t.me/SupraOracles
- **Twitter**: @SupraOracles
- **Docs**: https://docs.supra.com

## 🤝 Contributing

Veil Ecosystem is ready for deployment. To contribute:

1. Deploy to testnet using Option 1 or 2
2. Test functionality
3. Report issues
4. Suggest improvements
5. Build on top of Veil

## 📄 License

MIT License - See LICENSE file

## 🙏 Acknowledgments

- **Supra Team** - For L1 infrastructure
- **Move Language** - For secure smart contracts
- **OpenZeppelin** - For security patterns
- **Community** - For support and feedback

---

<div align="center">

**Built on Supra L1** | **Ready for Deployment** | **Sustainability: 9.8/10**

**18 Modules** | **$280M Revenue** | **49% APR** | **100% Supra Framework**

[Deploy Now](DEPLOY-NOW.md) | [Documentation](UNIFIED-TOKENOMICS-V17.md) | [Support](mailto:developers@supra.com)

</div>
