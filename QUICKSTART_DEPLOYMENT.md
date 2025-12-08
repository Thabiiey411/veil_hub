# Quick Start: Supra Account Setup & Contract Deployment

This guide walks you through initializing a Supra account and deploying Move contracts to Supra Testnet.

## Prerequisites
- Docker and Docker Compose installed and running
- This repository cloned locally

## Step 1: Start the Supra CLI Container

```bash
cd /path/to/veil_hub
./scripts/setup-supra-cli.sh
```

Verify the container is running:
```bash
docker ps --all | grep supra_cli
```

Expected output: `supra_cli` container listed as `Up`.

## Step 2: Create a Supra Account (Profile)

Enter the container shell:
```bash
./scripts/enter-supra-cli.sh
```

Inside the container, create a new profile with a new keypair (replace `accountA` with your choice):
```bash
supra profile new accountA --network testnet
```

This generates a keypair and stores it in the profile. The public key is displayed; save it for reference.

To view your profile (shows account address):
```bash
supra profile -l
```

To reveal the private key (use with caution—never share):
```bash
supra profile -l -r
```

## Step 3: Fund Your Account (Testnet Only)

Still inside the container, request testnet funds from the faucet:
```bash
supra move account fund-with-faucet --rpc-url https://rpc-testnet.supra.com
```

The faucet will fund the active profile. If you have multiple profiles, activate the one you want to fund first:
```bash
supra profile activate accountA
supra move account fund-with-faucet --rpc-url https://rpc-testnet.supra.com
```

## Step 4: Compile Your Move Package

Compile the Veil Hub Move modules:
```bash
supra move tool compile --package-dir /supra/move_workspace/exampleContract
```

Or (outside container) use the helper:
```bash
./scripts/enter-supra-cli.sh
# inside:
cd /path/to/move_workspace
supra move tool compile
```

## Step 5: Publish (Deploy) to Testnet

Inside the container:
```bash
supra move tool publish --package-dir /supra/move_workspace/exampleContract --rpc-url https://rpc-testnet.supra.com
```

The CLI will use your active profile to sign and submit the transaction. If successful, you'll see a published module address.

## Step 6: Verify Deployment

You can verify on the Supra network explorer using your account address. The explorer URL varies by testnet; consult Supra docs.

## CI/CD Deployment

For GitHub Actions CI deployment:

1. Add these secrets to your GitHub repository:
   - `SUPRA_PRIVATE_KEY` — your hex private key (from `supra profile -l -r`)
   - `NEXT_PUBLIC_SUPRA_TESTNET_RPC` — `https://rpc-testnet.supra.com`
   - `SUPRA_CLI_CMD` (optional) — the full supra CLI command if you prefer not to rely on `supra` being in PATH

2. The `./.github/workflows/deploy-move.yml` workflow will automatically compile and publish on push to `main`.

## Troubleshooting

**Container won't start**
- Ensure Docker is running: `docker --version` and check Docker Desktop is open (macOS/Windows).
- Check logs: `docker logs supra_cli`.

**Account fund-with-faucet fails**
- Verify you have internet connectivity and the RPC endpoint is reachable: `curl https://rpc-testnet.supra.com`.
- Check that you're using the correct profile (active one).

**Publish fails with "insufficient funds"**
- Request more testnet funds: `supra move account fund-with-faucet --rpc-url https://rpc-testnet.supra.com` (may need to wait a moment after funding).

**Can't find compiled artifacts**
- Artifacts are in `move/build/` after compilation. Ensure the compile step succeeded.

## Next Steps

- Review the Move source code in `./veil-hub-v2/move/sources/` to understand the contracts.
- Deploy to mainnet by modifying your profile: `supra profile modify accountA --network mainnet` (requires actual SUPRA tokens, not testnet tokens).
- Monitor deployments and debug issues using Supra's explorer and documentation.

For more info, see:
- `./SUPRA_CLI_DOCKER.md` — Supra CLI installation and detailed profile management.
- `./veil-hub-v2/DEPLOYMENT.md` — Frontend and backend deployment guides.
- Supra docs: https://docs.supra.com

