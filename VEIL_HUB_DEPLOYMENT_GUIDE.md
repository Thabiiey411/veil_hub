# Veil Hub dApp Deployment & Integration Guide

**Status:** Ready for deployment to Supra testnet  
**Last Updated:** December 9, 2025

## 📋 Executive Summary

You have **2 compiled Move packages** ready for Supra testnet:
- ✅ **HelloSupra** - Simple Hello World module (smoke test)
- ✅ **VeilHubCore** - Core Veil Hub module with counter and message storage

**Next Step:** Deploy via Supra Web Console, then integrate with the React dApp frontend.

---

## 🚀 Deployment Options

### Option 1: Supra Web Console (Recommended - 5 minutes)

1. Visit: **https://console.supra.com**
2. Connect your wallet (address: `0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026`)
3. Upload compiled packages from `/supra/move_workspace/`:
   - `/HelloSupra/build/HelloSupra/` → Deploy as "HelloSupra"
   - `/VeilHubCore/build/VeilHubCore/` → Deploy as "VeilHubCore"
4. Click "Deploy" for each package
5. Note the **Package Object IDs** from the deployment confirmation

**Advantages:**
- No CLI required
- Visual feedback
- Supra team support
- Testnet faucet integrated

---

### Option 2: Local Supra CLI

```bash
# Install Supra CLI locally (macOS/Linux)
curl --proto '=https' --tlsv1.2 -sSf https://supra.com/install_supra_cli.sh | sh

# Create profile
supra profile new my_deployer <PRIVATE_KEY> --network testnet

# Publish packages
supra move tool publish \
  --package-dir ./supra/move_workspace/HelloSupra \
  --rpc-url https://rpc-testnet.supra.com

supra move tool publish \
  --package-dir ./supra/move_workspace/VeilHubCore \
  --rpc-url https://rpc-testnet.supra.com
```

**Private Key (for testing only):**
```
0x1339610cbfbc335157de8575ae27dd3c8eb3843fb4a17f7b7fb4cc7ef772ec71
```

---

### Option 3: GitHub Actions CI/CD

Create `.github/workflows/deploy-supra.yml`:

```yaml
name: Deploy to Supra Testnet

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Supra CLI
        run: |
          curl --proto '=https' --tlsv1.2 -sSf https://supra.com/install_supra_cli.sh | sh
          export PATH="$HOME/.supra/bin:$PATH"
      
      - name: Deploy Contracts
        env:
          SUPRA_PRIVATE_KEY: ${{ secrets.SUPRA_PRIVATE_KEY }}
        run: |
          supra move tool publish \
            --package-dir ./supra/move_workspace/VeilHubCore \
            --rpc-url https://rpc-testnet.supra.com \
            --private-key $SUPRA_PRIVATE_KEY
```

---

## 📦 Compiled Artifacts

### HelloSupra
- **Location:** `/supra/move_workspace/HelloSupra/build/`
- **Module:** `hello_supra::hello`
- **Functions:** `hello() -> u64` (returns 42)
- **Size:** 473 bytes
- **Purpose:** Smoke test; verifies CLI and deployment flow

### VeilHubCore
- **Location:** `/supra/move_workspace/VeilHubCore/build/`
- **Module:** `veil_hub::core`
- **Functions:**
  - `init_veil_hub(account: &signer)` - Initialize Veil Hub state
  - `increment_counter(account: &signer)` - Increment counter
  - `set_message(account: &signer, msg: vector<u8>)` - Update message
  - `get_counter(addr: address) -> u64` - View counter
  - `get_message(addr: address) -> vector<u8>` - View message
- **Size:** ~1.5 KB
- **State:** Stores counter and message per account

---

## 🎯 Post-Deployment: dApp Integration

Once packages are deployed, integrate with the React frontend:

### 1. Update Environment Variables

```bash
# .env.local
NEXT_PUBLIC_SUPRA_RPC=https://rpc-testnet.supra.com
NEXT_PUBLIC_VEIL_HUB_PACKAGE_ID=0x<DEPLOYED_PACKAGE_ID>
NEXT_PUBLIC_VEIL_CORE_MODULE=veil_hub::core
```

### 2. Update `app/page.tsx`

```typescript
import { useSupraWallet } from "@/hooks/useSupraWallet";
import VeilHubClient from "@/lib/veil-hub-client";

export default function Home() {
  const { account, signAndExecuteTransactionBlock } = useSupraWallet();
  const veilClient = new VeilHubClient(
    process.env.NEXT_PUBLIC_SUPRA_RPC,
    process.env.NEXT_PUBLIC_VEIL_HUB_PACKAGE_ID
  );

  const handleInitVeilHub = async () => {
    try {
      const tx = await veilClient.initVeilHub();
      const result = await signAndExecuteTransactionBlock({ transactionBlock: tx });
      console.log("Veil Hub initialized:", result);
    } catch (error) {
      console.error("Error:", error);
    }
  };

  return (
    <main className="min-h-screen flex flex-col items-center justify-center gap-4">
      <h1 className="text-4xl font-bold">Veil Hub</h1>
      {account ? (
        <button
          onClick={handleInitVeilHub}
          className="px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700"
        >
          Initialize Veil Hub
        </button>
      ) : (
        <p>Connect wallet to continue</p>
      )}
    </main>
  );
}
```

### 3. Create Veil Hub Client

```bash
mkdir -p app/lib
touch app/lib/veil-hub-client.ts
```

See the full implementation in `/workspaces/veil_hub/veil-hub-v2/lib/veil-hub-client.ts` (create next).

---

## 🔗 Testnet Faucet

To get testnet SUPRA tokens:
```
https://rpc-testnet.supra.com/rpc/v1/wallet/faucet/0xf268c1cfa298b4c66ab9097fdc634b490b42204efb8be5b5adab160136846026
```

---

## ✅ Testing Checklist

- [ ] Packages compiled successfully
- [ ] Deployed to Supra testnet
- [ ] Package IDs noted
- [ ] dApp frontend environment variables updated
- [ ] Connected wallet to dApp
- [ ] Called `init_veil_hub` successfully
- [ ] Verified state changes on-chain

---

## 📚 Resources

- [Supra Docs](https://docs.supra.com)
- [Supra Move Getting Started](https://docs.supra.com/network/move/getting-started)
- [Your First dApp Guide](https://docs.supra.com/network/move/getting-started/your-first-dapp-with-starkey)
- [SupraScan Explorer](https://supraScan.io)

---

## 🔧 Troubleshooting

### Package compilation fails
- Ensure all `use` statements reference correct addresses in `Move.toml`
- Check that `supra` and `std` modules are available in your framework

### Deployment fails on Web Console
- Ensure wallet is funded from testnet faucet
- Verify package files include `Move.toml` and `sources/` directory

### dApp can't call contract
- Verify `NEXT_PUBLIC_VEIL_HUB_PACKAGE_ID` is set correctly
- Check that the transaction signer has gas tokens

---

**Next Step:** Deploy packages using Supra Web Console, then return here to integrate with the dApp frontend.
