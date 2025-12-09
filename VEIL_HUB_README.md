# 🌑 Veil Hub - Complete Supra L1 dApp

**A privacy-first decentralized application built on Supra Network**

[![Supra L1](https://img.shields.io/badge/Supra-L1-blue)](https://supra.com)
[![Move](https://img.shields.io/badge/Language-Move-orange)](https://move-language.github.io/move/)
[![Status](https://img.shields.io/badge/Status-Ready%20to%20Deploy-success)](./VEIL_HUB_DEPLOYMENT_GUIDE.md)
[![Next.js](https://img.shields.io/badge/Frontend-Next.js-black)](https://nextjs.org)

---

## 📖 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Compiled Contracts](#compiled-contracts)
4. [Quick Start](#quick-start)
5. [Deployment Guide](#deployment-guide)
6. [dApp Frontend](#dapp-frontend)
7. [Development](#development)

---

## 🎯 Project Overview

**Veil Hub** is a comprehensive Web3 DApp platform built on **Supra Network L1**, demonstrating:

- ✅ **Smart Contract Development** - Move modules compiled and ready for deployment
- ✅ **Full-Stack Integration** - React/Next.js frontend connected to on-chain contracts
- ✅ **User Experience** - Wallet integration, state management, real-time updates
- ✅ **Privacy-First Design** - Leveraging Supra's security and privacy features

### Key Features

| Feature | Description |
|---------|-------------|
| 🔐 **Secure State Storage** | On-chain counter and message storage per account |
| 👛 **Wallet Integration** | Starkey wallet support via Supra adapter |
| 🔄 **Real-Time Updates** | Live state synchronization after transactions |
| ⚡ **Fast Transactions** | Low gas, high throughput on Supra L1 |
| 🎨 **Modern UI** | Tailwind CSS with responsive design |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│         Veil Hub dApp Frontend              │
│    (Next.js + React + Tailwind CSS)         │
│                                             │
│  • Wallet Connection (Starkey)              │
│  • State Management                         │
│  • Transaction Signing                      │
└────────────────┬────────────────────────────┘
                 │
         ┌──────┴──────┐
         ▼             ▼
    VeilHubClient  useWallet Hook
    Library        (Supra Adapter)
         │             │
         └──────┬──────┘
                ▼
    ┌──────────────────────────┐
    │  Supra Network (Testnet) │
    │                          │
    │  ✅ HelloSupra           │
    │  ✅ VeilHubCore          │
    └──────────────────────────┘
         (RPC: testnet.supra.com)
```

---

## 📦 Compiled Contracts

### 1. HelloSupra (Smoke Test)
```
Location:  /supra/move_workspace/HelloSupra/
Module:    hello_supra::hello
Function:  hello() -> u64  (returns 42)
Size:      473 bytes
```

**Purpose:** Verify deployment pipeline works correctly.

### 2. VeilHubCore (Main dApp)
```
Location:  /supra/move_workspace/VeilHubCore/
Module:    veil_hub::core
```

**Functions:**
- `init_veil_hub(account: &signer)` - Initialize account state
- `increment_counter(account: &signer)` - Increment counter
- `set_message(account: &signer, msg: vector<u8>)` - Update message
- `get_counter(addr: address) -> u64` - View counter
- `get_message(addr: address) -> vector<u8>` - View message

**Data Structure:**
```move
struct VeilState has key {
    counter: u64,
    message: vector<u8>,
}
```

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- pnpm or npm
- Starkey Wallet (or any Supra-compatible wallet)
- Testnet SUPRA tokens (free from faucet)

### 1. Install Dependencies

```bash
cd veil-hub-v2
pnpm install
```

### 2. Deploy Contracts (See next section)

### 3. Configure Environment

```bash
# Copy example env
cp .env.example .env.local

# Update with deployed package ID
# NEXT_PUBLIC_VEIL_HUB_PACKAGE_ID=0x<YOUR_PACKAGE_ID>
```

### 4. Run dApp

```bash
pnpm dev
```

Visit `http://localhost:3000` and click "Veil Hub" in the navigation.

---

## 📋 Deployment Guide

### ⚠️ Prerequisites

1. **Fund your account** - Get testnet SUPRA tokens:
   ```
   https://rpc-testnet.supra.com/rpc/v1/wallet/faucet/0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026
   ```

2. **Wallet address:**
   ```
   0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026
   ```

### Deployment Options

#### Option A: Supra Web Console (Recommended)
1. Visit: https://console.supra.com
2. Connect wallet
3. Upload compiled packages:
   - `/supra/move_workspace/HelloSupra/build/`
   - `/supra/move_workspace/VeilHubCore/build/`
4. Deploy and note Package IDs

**Time:** ~5 minutes  
**Difficulty:** ⭐ (Easiest)

#### Option B: Local CLI
```bash
# Install
curl --proto '=https' --tlsv1.2 -sSf https://supra.com/install_supra_cli.sh | sh

# Deploy
supra move tool publish \
  --package-dir ./supra/move_workspace/VeilHubCore \
  --rpc-url https://rpc-testnet.supra.com
```

**Time:** ~3-5 minutes  
**Difficulty:** ⭐⭐ (Intermediate)

#### Option C: CI/CD (GitHub Actions)
See `.github/workflows/deploy-supra.yml` template

**Time:** Automatic  
**Difficulty:** ⭐⭐⭐ (Advanced)

### Post-Deployment

1. Note the **Package Object ID** from deployment output
2. Update `.env.local`:
   ```
   NEXT_PUBLIC_VEIL_HUB_PACKAGE_ID=0x<ID>
   ```
3. Restart dApp (`pnpm dev`)
4. Connect wallet and test!

**See:** [Full Deployment Guide](./VEIL_HUB_DEPLOYMENT_GUIDE.md)

---

## 💻 dApp Frontend

### Components

#### `app/veil-hub/page.tsx` (Main Page)
- Wallet connection UI
- State initialization
- Counter and message display
- Transaction submission

#### `lib/veil-hub-client.ts` (Contract Client)
- Abstracts Supra client calls
- Type-safe function wrappers
- State fetching and parsing
- Error handling

#### `hooks/useSupraWallet.ts` (Wallet Integration)
- Wallet connection logic
- Transaction signing
- Balance tracking

### Key Functions

```typescript
// Initialize
await veilClient.initVeilHub()

// Update state
await veilClient.incrementCounter(address)
await veilClient.setMessage(address, "Hello!")

// Read state
const counter = await veilClient.getCounter(address)
const message = await veilClient.getMessage(address)
const state = await veilClient.getVeilHubState(address)
```

### UI Flow

```
┌─────────────────────────────┐
│  Veil Hub Page              │
├─────────────────────────────┤
│  [Connect Wallet]           │
└──────────────┬──────────────┘
               │ Connected ✓
         ┌─────▼─────┐
         │Initialized?
         │   NO     YES
         │  ▼       ▼
    [Init]  Dashboard
    Button  ├─ Counter Card
            │  └─ [+] Button
            ├─ Message Card
            │  ├─ Display
            │  └─ [Set] Button
            └─ About Section
```

---

## 🛠️ Development

### Project Structure

```
veil-hub-v2/
├── app/
│   ├── layout.tsx          # Main layout
│   ├── page.tsx            # Home page
│   ├── veil-hub/
│   │   └── page.tsx        # Veil Hub dApp (MAIN)
│   ├── globals.css         # Global styles
│   └── providers.tsx       # Wallet provider setup
├── components/
│   └── (UI components)
├── lib/
│   ├── veil-hub-client.ts  # Veil Hub client (MAIN)
│   ├── supra-config.ts     # Supra RPC config
│   └── contracts.ts        # Contract helpers
├── hooks/
│   ├── useSupraWallet.ts   # Wallet hook (MAIN)
│   └── (other hooks)
├── move/
│   ├── Move.toml           # Move package config
│   └── sources/            # Move module source
├── supra/
│   └── move_workspace/
│       ├── HelloSupra/     # Smoke test module
│       └── VeilHubCore/    # Main module
└── (config files)
```

### Adding New Contract Functions

1. **Add Move function** in `/supra/move_workspace/VeilHubCore/sources/core.move`
2. **Compile:**
   ```bash
   docker exec supra_cli /supra/supra move tool compile \
     --package-dir /supra/move_workspace/VeilHubCore
   ```
3. **Add client method** in `lib/veil-hub-client.ts`
4. **Deploy** via Web Console or CLI
5. **Update dApp** to call new method

### Testing

```bash
# Run tests
pnpm test

# Build
pnpm build

# Lint
pnpm lint
```

---

## 📚 Resources

| Resource | Link |
|----------|------|
| Supra Docs | https://docs.supra.com |
| Move Book | https://move-language.github.io/move/ |
| Supra Console | https://console.supra.com |
| SupraScan | https://supraScan.io |
| Your First dApp | https://docs.supra.com/network/move/getting-started/your-first-dapp-with-starkey |

---

## 🔐 Security Notes

⚠️ **FOR TESTNET ONLY**
- Private key in this README is for testnet testing only
- Never use on mainnet
- Always keep private keys secure
- Audit contracts before mainnet deployment

---

## 🤝 Contributing

This is a demonstration project. To extend:

1. Add more Move modules
2. Expand dApp features
3. Optimize contracts
4. Improve UI/UX
5. Add tests

---

## 📝 License

MIT

---

## 🎓 Learning Path

1. **Start:** Read [Quick Start](#quick-start)
2. **Deploy:** Follow [Deployment Guide](#deployment-guide)
3. **Interact:** Test dApp at `localhost:3000`
4. **Explore:** Check [Source Code](#development)
5. **Extend:** Add new features!

---

## 🆘 Troubleshooting

### Wallet not connecting?
- Ensure Starkey is installed
- Try refreshing page
- Check wallet settings

### Transactions failing?
- Verify account is funded from faucet
- Check RPC URL is correct
- Ensure Package ID is set in `.env.local`

### dApp showing "0x0" package ID?
- Deploy contracts first
- Update Package ID in `.env.local`
- Restart dev server

**Need help?** See [Full Deployment Guide](./VEIL_HUB_DEPLOYMENT_GUIDE.md)

---

**Status:** ✅ Ready for Supra testnet deployment  
**Last Updated:** December 9, 2025  
**Wallet:** `0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026`
