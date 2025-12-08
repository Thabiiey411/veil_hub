# Supra CLI (Docker) — Installation & Usage

This document explains how to install and run the Supra CLI via Docker Compose, and how to use it to compile and publish Move packages.

Prerequisites
- Docker (Docker Desktop or Docker Engine) installed and running.
- curl installed (to fetch the remote compose file).

Quick install (recommended)

1. From the repository root run:

```bash
# start the Supra CLI container (creates ./supra/ if missing)
./scripts/setup-supra-cli.sh
```

2. Verify the container is running:

```bash
docker ps --all
```

3. Enter the Supra CLI container shell:

```bash
./scripts/enter-supra-cli.sh
# once inside the container, use `supra` as the CLI binary, e.g.:
supra --help
```

Commands you will run inside the container

- Compile your Move package (run from package directory or pass --package-dir):

```bash
supra move tool compile --package-dir /supra/move_workspace/exampleContract
```

- Request testnet funds from faucet (if needed):

```bash
supra move account fund-with-faucet --rpc-url https://rpc-testnet.supra.com
```

- Publish package to testnet:

```bash
supra move tool publish --package-dir /supra/move_workspace/exampleContract --rpc-url https://rpc-testnet.supra.com
```

Notes
- The compose YAML is pulled from the official Supra repository. If you'd like to pin a version, download the compose file and store it under `./supra/compose.yaml` and run `docker compose -f supra/compose.yaml up -d`.
- The container exposes a bind-mounted `supra/configs` directory (in most official compose setups) — this allows CLI profiles to persist between container restarts.
- The container binary is `supra` (aliased in the compose file). Use `--help` to inspect available commands prior to running them.

Profiles and Keys (create / import / manage)
------------------------------------------------
You can create and manage Supra CLI profiles from inside the container. To make this easy we provide helper scripts that execute the equivalent `supra profile` commands inside the running container.

Important safety note: listing with the reveal flag or otherwise printing private keys to your terminal can leak secrets if you're recording, streaming, or sharing your screen. Always be careful.

Helper scripts (run from repository root):

- Create a new profile (generates a new keypair)

```bash
./scripts/supra-profile-new.sh accountA --network testnet
```

- Import an existing private key into a profile (WARNING: passing keys on the CLI may be visible in process lists/history)

```bash
./scripts/supra-profile-import.sh accountA <HEX_PRIVATE_KEY> --network testnet
```

- Modify a profile's network settings (e.g., switch to mainnet)

```bash
./scripts/supra-profile-modify.sh accountA --network mainnet
```

- Activate a profile (subsequent supra commands will use the active profile)

```bash
./scripts/supra-profile-activate.sh accountA
```

- List profiles (use -r to reveal private keys; DO NOT do this in an unsafe context)

```bash
./scripts/supra-profile-list.sh
./scripts/supra-profile-list.sh -r   # reveals private keys (use with extreme caution)
```

Migration note
If you upgraded from an older CLI version that used the deprecated `key` command, run the migration inside the container:

```bash
./scripts/enter-supra-cli.sh
supra profile migrate
```

After migration, verify and modify profiles as needed with `supra profile modify`.

Updating the CLI
- To update to the latest CLI image, re-run `./scripts/setup-supra-cli.sh` to pull the latest compose config/image, or pull manually:

```bash
curl https://raw.githubusercontent.com/supra-labs/supra-dev-hub/refs/heads/main/Scripts/cli/compose.yaml | docker compose -f - pull
docker compose -f - up -d
```

Security
- Do not place private keys in plaintext inside the repo. Use `supra` profiles (persisted in `supra/configs`) or environment variables in CI.
- For CI deployments, prefer providing the full `SUPRA_CLI_CMD` as a GitHub Secret, or install the `supra` CLI in the CI image and supply `SUPRA_PRIVATE_KEY` as a secret.
