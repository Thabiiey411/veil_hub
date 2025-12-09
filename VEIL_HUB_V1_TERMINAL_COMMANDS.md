# 🚀 Veil Hub V1 - Terminal Commands Only
## Complete Setup from Scratch (Backend Only, No Frontend)

---

## 📋 Pre-Requisites
- Linux or macOS
- sudo access (for Docker installation)
- Git & curl installed
- Internet connection
- At least 5GB free disk space

---

## 🔧 STEP 1: Install Docker & Docker Compose

### For Linux (Ubuntu/Debian):
```bash
# Update package manager
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify Docker installation
docker --version
docker run hello-world

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### For macOS:
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker & Docker Compose
brew install docker docker-compose

# Start Docker Desktop
open -a Docker

# Verify installations
docker --version
docker-compose --version
```

---

## 📦 STEP 2: Clone Veil Hub V1 Repository

```bash
# Navigate to home directory
cd ~

# Clone the repository
git clone https://github.com/Thabiiey411/veil_hub.git VeilHubV1

# Navigate into the repository
cd VeilHubV1

# Verify clone
pwd
ls -la
```

---

## 🐳 STEP 3: Setup Supra CLI Docker Container

```bash
# Navigate to repo root
cd ~/VeilHubV1

# Make setup script executable
chmod +x scripts/setup-supra-cli.sh

# Run setup script (this will pull and start the container)
bash scripts/setup-supra-cli.sh

# Verify container is running
docker ps

# Expected output: veil-supra-cli container should be listed
```

**Verify container is ready:**
```bash
# Check if container is healthy
docker ps | grep veil-supra-cli

# View container logs
docker logs veil-supra-cli

# Expected: No errors, container should be running
```

---

## 👤 STEP 4: Initialize Supra Account (Create Profile)

### Create a new Supra account profile:
```bash
# Make init script executable
chmod +x scripts/init-supra-account.sh

# Create account named "accountA" on testnet
bash scripts/init-supra-account.sh accountA testnet

# Script will:
# 1. Create a new Move profile
# 2. Activate the profile
# 3. List all profiles
# 4. Request testnet funds from faucet
```

### Alternative: Create custom account:
```bash
# Inside container, create custom profile
docker exec veil-supra-cli supra move account create --profile-name myaccount

# Activate it
docker exec veil-supra-cli supra move account activate --profile-name myaccount

# Get account address
docker exec veil-supra-cli supra move account address --profile-name myaccount

# Request testnet funds
docker exec veil-supra-cli supra move account fund-with-faucet --rpc-url https://rpc-testnet.supra.com
```

### List all profiles:
```bash
bash scripts/supra-profile-list.sh

# Or directly:
docker exec veil-supra-cli supra move account list
```

---

## 📦 STEP 5: Compile Move Contracts

### Compile VeilHub package:
```bash
# Navigate to repo
cd ~/VeilHubV1

# Compile VeilHub contracts
docker exec veil-supra-cli supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub

# Expected: No errors, "Compiling, linking and optimizing package" message
```

### Compile Veil Testnet package:
```bash
# Compile Veil Testnet contracts
docker exec veil-supra-cli supra move tool compile --package-dir /workspace/supra/veil_testnet

# Expected: Same success message
```

### Verify build artifacts:
```bash
# Check if build directory was created
ls -la supra/move_workspace/VeilHub/build/

# Should contain compiled modules
```

---

## 🚀 STEP 6: Deploy Contracts to Supra Testnet

### Deploy VeilHub to testnet:
```bash
# Navigate to repo root
cd ~/VeilHubV1

# Make deploy script executable
chmod +x scripts/deploy-move.sh

# Deploy to testnet
bash scripts/deploy-move.sh

# Script will:
# 1. Check for SUPRA_PRIVATE_KEY and RPC URL
# 2. Compile the contracts
# 3. Request faucet funds if needed
# 4. Publish contracts to chain
```

### Direct deployment command:
```bash
# Set environment variables
export SUPRA_PRIVATE_KEY="accountA"
export NEXT_PUBLIC_SUPRA_TESTNET_RPC="https://rpc-testnet.supra.com"

# Compile
docker exec veil-supra-cli supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub

# Publish to testnet
docker exec veil-supra-cli supra move tool publish \
  --package-dir /workspace/supra/move_workspace/VeilHub \
  --rpc-url https://rpc-testnet.supra.com
```

### Deploy to mainnet (when ready):
```bash
export SUPRA_PRIVATE_KEY="accountA"
export NEXT_PUBLIC_SUPRA_MAINNET_RPC="https://rpc-mainnet.supra.com"

# Compile
docker exec veil-supra-cli supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub

# Publish to mainnet
docker exec veil-supra-cli supra move tool publish \
  --package-dir /workspace/supra/move_workspace/VeilHub \
  --rpc-url https://rpc-mainnet.supra.com
```

---

## 🔍 STEP 7: Verify Deployment

### Get account address:
```bash
docker exec veil-supra-cli supra move account address --profile-name accountA
```

### List deployed objects:
```bash
# Replace YOUR_ADDRESS with actual address from previous command
docker exec veil-supra-cli supra move object list \
  --address YOUR_ADDRESS \
  --rpc-url https://rpc-testnet.supra.com
```

### Inspect deployed objects:
```bash
# Replace OBJECT_ID with ID from list output
docker exec veil-supra-cli supra move object inspect \
  --object-id OBJECT_ID \
  --rpc-url https://rpc-testnet.supra.com
```

### View on Supra Explorer:
```bash
# Open in browser (replace YOUR_ADDRESS with actual address)
# Testnet: https://testnet.suprascan.io/account/YOUR_ADDRESS
# Mainnet: https://suprascan.io/account/YOUR_ADDRESS
```

---

## 🛠️ Container Management Commands

### Enter interactive container shell:
```bash
docker exec -it veil-supra-cli /bin/bash

# Once inside, you can run Supra commands directly:
supra move account list
supra move account address --profile-name accountA
supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub
```

### Stop container:
```bash
docker stop veil-supra-cli
```

### Start container:
```bash
docker start veil-supra-cli
```

### Remove container (if needed):
```bash
docker rm veil-supra-cli
```

### View container logs:
```bash
docker logs -f veil-supra-cli
```

### View running containers:
```bash
docker ps
```

### View all containers (including stopped):
```bash
docker ps -a
```

---

## 📝 Account Management

### Create multiple accounts:
```bash
# Create account 1
docker exec veil-supra-cli supra move account create --profile-name account1

# Create account 2
docker exec veil-supra-cli supra move account create --profile-name account2

# Create account 3
docker exec veil-supra-cli supra move account create --profile-name account3
```

### Switch between accounts:
```bash
# Activate account1
docker exec veil-supra-cli supra move account activate --profile-name account1

# Get its address
docker exec veil-supra-cli supra move account address --profile-name account1

# Activate account2
docker exec veil-supra-cli supra move account activate --profile-name account2

# Get its address
docker exec veil-supra-cli supra move account address --profile-name account2
```

### List all accounts:
```bash
docker exec veil-supra-cli supra move account list
```

### Delete account (use with caution):
```bash
docker exec veil-supra-cli supra move account delete --profile-name accountname
```

---

## 🔗 Network Endpoints

### Testnet:
```bash
# RPC Endpoint
https://rpc-testnet.supra.com

# Chain ID
6

# Explorer
https://testnet.suprascan.io

# Faucet
https://rpc-testnet.supra.com/rpc/v1/wallet/faucet
```

### Mainnet:
```bash
# RPC Endpoint
https://rpc-mainnet.supra.com

# Chain ID
999

# Explorer
https://suprascan.io
```

---

## 📁 Project Structure

```
~/VeilHubV1/
├── supra/
│   ├── move_workspace/
│   │   └── VeilHub/              (Main contracts)
│   │       ├── sources/          (Contract code)
│   │       ├── Move.toml         (Package manifest)
│   │       └── build/            (Compiled output)
│   └── veil_testnet/             (Alternative contracts)
│       ├── sources/
│       ├── Move.toml
│       └── build/
├── scripts/
│   ├── setup-supra-cli.sh        (Install Supra CLI)
│   ├── init-supra-account.sh     (Create account)
│   ├── enter-supra-cli.sh        (Open container shell)
│   ├── deploy-move.sh            (Deploy contracts)
│   ├── supra-profile-*.sh        (Profile management)
│   └── ...
├── QUICKSTART_DEPLOYMENT.md      (Full guide)
├── SUPRA_CLI_DOCKER.md           (CLI reference)
└── README.md
```

---

## ⚡ Quick Reference - All Commands in Order

```bash
# 1. Install Docker (Linux)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 2. Clone repo
cd ~ && git clone https://github.com/Thabiiey411/veil_hub.git VeilHubV1 && cd VeilHubV1

# 3. Setup Supra CLI
bash scripts/setup-supra-cli.sh

# 4. Create account
bash scripts/init-supra-account.sh accountA testnet

# 5. Compile contracts
docker exec veil-supra-cli supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub

# 6. Deploy to testnet
export SUPRA_PRIVATE_KEY="accountA"
docker exec veil-supra-cli supra move tool publish --package-dir /workspace/supra/move_workspace/VeilHub --rpc-url https://rpc-testnet.supra.com

# 7. Verify
docker exec veil-supra-cli supra move account address --profile-name accountA
docker exec veil-supra-cli supra move object list --address <ADDRESS> --rpc-url https://rpc-testnet.supra.com

# 8. View on explorer
# https://testnet.suprascan.io/account/<ADDRESS>
```

---

## ❓ Troubleshooting

### Docker daemon not running:
```bash
# Linux
sudo systemctl start docker

# macOS
open -a Docker
```

### Permission denied (docker):
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or use sudo
sudo docker ps
```

### Container won't start:
```bash
# Remove and recreate
docker rm -f veil-supra-cli
bash scripts/setup-supra-cli.sh
```

### Account not found:
```bash
# List existing accounts
docker exec veil-supra-cli supra move account list

# Create new one
docker exec veil-supra-cli supra move account create --profile-name newaccount
docker exec veil-supra-cli supra move account activate --profile-name newaccount
```

### Compilation errors:
```bash
# Clean and rebuild
docker exec veil-supra-cli bash -c "cd /workspace/supra/move_workspace/VeilHub && rm -rf build && supra move tool compile --package-dir ."
```

### Insufficient funds:
```bash
# Request more faucet funds
docker exec veil-supra-cli supra move account fund-with-faucet --rpc-url https://rpc-testnet.supra.com
```

---

## 📚 Additional Resources

- **Supra Docs**: https://docs.supra.com
- **Move Language**: https://docs.supra.com/move
- **Supra Explorer**: https://testnet.suprascan.io / https://suprascan.io
- **Discord Support**: https://discord.gg/supra

---

## ✅ Success Checklist

- [ ] Docker installed and running
- [ ] Repository cloned to ~/VeilHubV1
- [ ] Supra CLI container running
- [ ] Account created and activated
- [ ] Testnet funds received
- [ ] Contracts compiled successfully
- [ ] Contracts published to testnet
- [ ] Deployment verified on explorer

---

**Generated**: December 8, 2025  
**Status**: ✅ Production Ready  
**Backend Only**: No frontend included

