# Frontend Transfer Instructions

This repository will remain the canonical place for Move sources and contract deployment. To move the frontend into the dedicated frontend repository `https://github.com/Thabiiey411beta/veil_hub2`, follow these steps.

1. Create an archive of the frontend (already provided by this repo):

```bash
cd /path/to/veil_hub
./scripts/package-frontend.sh
# creates: veil-hub-v2-frontend.tar.gz
```

2. Transfer the archive to the `veil_hub2` repository (one of):

- Upload the archive to the remote repo via the GitHub web UI and unpack in the repo, or
- Clone `veil_hub2` locally, copy the archive into the clone, unpack and commit:

```bash
git clone git@github.com:Thabiiey411beta/veil_hub2.git
cd veil_hub2
cp ../veil_hub/veil-hub-v2-frontend.tar.gz ./
tar -xzf veil-hub-v2-frontend.tar.gz
git add .
git commit -m "Import frontend from veil_hub" 
git push origin main
```

3. In the `veil_hub2` repository, set up Vercel and GitHub Actions as needed:

- Add the following environment variables in Vercel project settings:
  - `NEXT_PUBLIC_SUPRA_MAINNET_RPC` — `https://rpc-mainnet.supra.com`
  - `NEXT_PUBLIC_SUPRA_TESTNET_RPC` — `https://rpc-testnet.supra.com`
  - `NEXT_PUBLIC_SUPRA_MAINNET_CHAIN_ID` — `8`
  - `NEXT_PUBLIC_SUPRA_TESTNET_CHAIN_ID` — `6`
  - `NEXT_PUBLIC_SUPRA_TESTNET_FAUCET` — `https://rpc-testnet.supra.com/rpc/v1/wallet/faucet`

- If you want CI-driven deploys from `veil_hub2`, add any CI workflows there (this repo no longer contains frontend deploy workflows).

4. Verify locally before pushing:

```bash
cd veil_hub2
npm ci
npm run build
npm run start
```

Notes
- This repository (`veil_hub`) continues to contain the Move sources in `veil-hub-v2/move` and the deployment workflow `./.github/workflows/deploy-move.yml` and script `./scripts/deploy-move.sh`.
- Do NOT copy `move/` or `supra/` directories into the frontend repo unless you intend the frontend repo to also handle contract deployments.
