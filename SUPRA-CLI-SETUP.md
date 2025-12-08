Supra CLI Setup (Docker)

This document shows how to run the Supra CLI in a container and use it to build and deploy Move contracts.

Prerequisites
- Docker Engine / Docker Desktop installed and running.
- (Optional) `docker-compose` or Docker Compose v2 (`docker compose`) available.

Quick start (use local compose):

1. Start container (from repository root):

```bash
./scripts/start-supra.sh
```

2. Check the container is running:

```bash
docker ps --all | grep veil-supra-cli
```

3. Enter the container shell:

```bash
./scripts/enter-supra.sh
# or
# docker exec -it veil-supra-cli /bin/bash
```

Inside the container
- The working directory (in this repository) is mounted to `/app/move`.
- The `supra` binary is available inside the container. Run `supra --help` to see top-level commands.

Common commands (inside container):
- Build Move project:

```bash
supra move build
```

- Initialize a new move module in the current directory:

```bash
supra move tool init
```

- (Example) Publish contracts to testnet/mainnet:

```bash
# Build first
supra move build

# Publish (example, replace flags with your keys and network)
supra move publish --network testnet --private-key-file /home/developer/.supra/keys/test-key.json
```

Note: The exact publish command and flags depend on the Supra CLI version. Run `supra move publish --help` inside the container to see available flags and options.

Using the upstream compose (recommended to get latest image)

If you prefer using the official compose file directly from Supra's repo (it will create a `supra` directory locally):

```bash
curl https://raw.githubusercontent.com/supra-labs/supra-dev-hub/refs/heads/main/Scripts/cli/compose.yaml | docker compose -f - up -d
```

Then proceed to `docker exec -it supra_cli /bin/bash` (container name in upstream compose may be `supra_cli`).

Volumes & config
- `./veil-hub-v2/move` in this repo is mounted into the container at `/app/move`.
- A `supra-cache` Docker volume is used for caching keys/configs. You can map `~/.supra` for persistent keys (read-only in `docker-compose.supra.yml` by default).

Creating and managing Supra profiles (keys)

Supra CLI (v9.x and later) uses a `profile` system. If you upgraded from older CLI versions (v6.x), you must migrate existing key files before using profiles:

```bash
# Run this once after an upgrade
./scripts/supra-profile-migrate.sh
```

Generate a new profile (inside container via helper script):

```bash
./scripts/supra-profile-new.sh accountA         # generates a new key/profile named accountA (defaults to testnet)

# or import an existing private key into a profile
./scripts/supra-profile-new.sh accountB "0x012345..." testnet
```

List created profiles:

```bash
./scripts/supra-profile-list.sh
```

Notes:
- Profile names must be unique. Attempting to create or import a profile with an existing name will error.
- Private keys should never be committed to source control. Use a host-mounted `~/.supra` or Docker secrets to persist and protect keys.

Security notes
- Keep private keys off the repository. Use a host-mounted `~/.supra` or Docker secrets for private key files.

If you want, I can:
- Adjust the `docker-compose.supra.yml` to mount a host `~/.supra` (read-write) so you can persist keys.
- Add an example `supra` key file template (never include real keys).
- Create a small deploy script that runs build + publish for a specified network.
