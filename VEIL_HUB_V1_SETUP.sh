#!/bin/bash

################################################################################
#                                                                              #
#                    🚀 VEIL HUB V1 - COMPLETE SETUP SCRIPT                   #
#                                                                              #
#                         Clone → Docker → Supra CLI                          #
#                              → Deploy Contracts                             #
#                                                                              #
#                          Backend Only (No Frontend)                         #
#                                                                              #
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_section() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

log_step() {
    echo -e "${CYAN}→${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

################################################################################
# STEP 1: CHECK SYSTEM REQUIREMENTS
################################################################################

log_section "STEP 1: System Requirements Check"

log_step "Checking OS..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    log_success "Linux detected"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    log_success "macOS detected"
else
    log_error "Unsupported OS: $OSTYPE"
    exit 1
fi

log_step "Checking internet connection..."
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    log_success "Internet connection OK"
else
    log_warning "No internet connection detected - some operations may fail"
fi

log_step "Checking required commands..."
for cmd in git curl; do
    if command -v $cmd &> /dev/null; then
        log_success "$cmd is installed"
    else
        log_error "$cmd is not installed"
        exit 1
    fi
done

################################################################################
# STEP 2: CLONE VEIL HUB V1 REPOSITORY
################################################################################

log_section "STEP 2: Clone Veil Hub V1 Repository"

REPO_URL="https://github.com/Thabiiey411/veil_hub.git"
REPO_DIR="${HOME}/VeilHubV1"

if [ -d "$REPO_DIR" ]; then
    log_warning "Repository already exists at $REPO_DIR"
    read -p "Do you want to remove it and clone fresh? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_step "Removing existing repository..."
        rm -rf "$REPO_DIR"
        log_success "Removed"
    else
        log_step "Using existing repository at $REPO_DIR"
    fi
fi

if [ ! -d "$REPO_DIR" ]; then
    log_step "Cloning repository from $REPO_URL..."
    git clone "$REPO_URL" "$REPO_DIR"
    log_success "Repository cloned to $REPO_DIR"
else
    log_step "Repository directory already exists, pulling latest changes..."
    cd "$REPO_DIR"
    git pull origin main
    log_success "Repository updated"
fi

cd "$REPO_DIR"
log_success "Working directory set to: $(pwd)"

################################################################################
# STEP 3: INSTALL DOCKER
################################################################################

log_section "STEP 3: Install Docker & Docker Compose"

if command -v docker &> /dev/null; then
    log_success "Docker is already installed"
    docker --version
else
    log_step "Installing Docker..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux installation
        sudo apt-get update
        sudo apt-get install -y curl
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
        
        # Add current user to docker group
        sudo usermod -aG docker $USER
        log_warning "You may need to logout and login again, or run: newgrp docker"
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS installation (requires Homebrew)
        if ! command -v brew &> /dev/null; then
            log_error "Homebrew not found. Install from https://brew.sh"
            exit 1
        fi
        brew install docker docker-compose
        log_step "Starting Docker Desktop..."
        open -a Docker
        sleep 10
    fi
    
    log_success "Docker installed"
    docker --version
fi

if command -v docker-compose &> /dev/null; then
    log_success "Docker Compose is already installed"
    docker-compose --version
else
    log_step "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    log_success "Docker Compose installed"
    docker-compose --version
fi

################################################################################
# STEP 4: VERIFY DOCKER DAEMON
################################################################################

log_section "STEP 4: Verify Docker Daemon"

log_step "Checking Docker daemon..."
if ! docker ps > /dev/null 2>&1; then
    log_warning "Docker daemon not running"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log_step "Starting Docker daemon..."
        sudo systemctl start docker
        sleep 3
    fi
fi

if docker ps > /dev/null 2>&1; then
    log_success "Docker daemon is running"
else
    log_error "Failed to connect to Docker daemon"
    log_step "Try: sudo systemctl start docker (Linux) or open Docker Desktop (macOS)"
    exit 1
fi

################################################################################
# STEP 5: SETUP SUPRA CLI WITH DOCKER
################################################################################

log_section "STEP 5: Setup Supra CLI Docker Container"

cd "$REPO_DIR"

log_step "Making setup script executable..."
chmod +x scripts/setup-supra-cli.sh

log_step "Running Supra CLI setup..."
bash scripts/setup-supra-cli.sh

log_success "Supra CLI container setup complete"

# Wait for container to be ready
log_step "Waiting for Supra CLI container to be ready..."
sleep 5

# Verify container is running
if docker ps | grep -q veil-supra-cli; then
    log_success "Supra CLI container is running"
    docker ps | grep veil-supra-cli
else
    log_error "Supra CLI container not running"
    exit 1
fi

################################################################################
# STEP 6: INITIALIZE SUPRA ACCOUNT
################################################################################

log_section "STEP 6: Initialize Supra Account with Faucet"

cd "$REPO_DIR"

log_step "Making init script executable..."
chmod +x scripts/init-supra-account.sh

log_step "Running account initialization..."
log_warning "This will create a new Supra account and request testnet funds from faucet"
echo ""
read -p "Enter account name (default: accountA): " account_name
account_name=${account_name:-accountA}

read -p "Enter network (testnet/mainnet, default: testnet): " network
network=${network:-testnet}

bash scripts/init-supra-account.sh "$account_name" "$network"

log_success "Account initialized: $account_name on $network"

################################################################################
# STEP 7: VERIFY ACCOUNT
################################################################################

log_section "STEP 7: Verify Account Setup"

log_step "Listing Supra profiles..."
bash scripts/supra-profile-list.sh

################################################################################
# STEP 8: COMPILE MOVE CONTRACTS
################################################################################

log_section "STEP 8: Compile Move Contracts"

cd "$REPO_DIR"

log_step "Navigating to Move workspace..."
cd supra/move_workspace/VeilHub

log_step "Current directory: $(pwd)"

log_step "Building Move package..."
docker exec veil-supra-cli supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub

log_success "Move contracts compiled successfully"

log_step "Checking build artifacts..."
if [ -d "build" ]; then
    log_success "Build directory created"
    ls -la build/
else
    log_error "Build directory not found"
fi

################################################################################
# STEP 9: DEPLOY CONTRACTS TO SUPRA TESTNET
################################################################################

log_section "STEP 9: Deploy Contracts to Supra Testnet"

cd "$REPO_DIR"

log_step "Navigating to root directory..."
cd "$REPO_DIR"

log_step "Making deploy script executable..."
chmod +x scripts/deploy-move.sh

log_warning "Deploying contracts to Supra Testnet"
log_step "This will publish your Move contracts on-chain"
echo ""
read -p "Continue with deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warning "Deployment cancelled"
else
    log_step "Running deployment..."
    
    # Set environment variables
    export SUPRA_PRIVATE_KEY="$account_name"
    export NEXT_PUBLIC_SUPRA_TESTNET_RPC="https://rpc-testnet.supra.com"
    
    bash scripts/deploy-move.sh
    
    log_success "Contracts deployed to Supra Testnet"
fi

################################################################################
# STEP 10: VERIFY DEPLOYMENT
################################################################################

log_section "STEP 10: Verify Deployment"

log_step "Checking deployed modules..."
docker exec veil-supra-cli supra move object inspect --object-ids 0x0 --rpc-url https://rpc-testnet.supra.com || true

log_step "View deployment details:"
log_warning "Visit Supra Testnet Explorer: https://testnet.suprascan.io"
log_warning "Search for your account address from the deployment output above"

################################################################################
# STEP 11: SETUP SUMMARY
################################################################################

log_section "STEP 11: Setup Complete! 🎉"

cat << 'EOF'

╔════════════════════════════════════════════════════════════════════════╗
║                    ✅ VEIL HUB V1 SETUP COMPLETE                      ║
╚════════════════════════════════════════════════════════════════════════╝

📁 Repository Location: ~/VeilHubV1

🐳 Docker Containers:
   • veil-supra-cli (Supra CLI container)

🔧 Available Commands:

   Enter Supra CLI:
   $ ./scripts/enter-supra-cli.sh

   Stop Supra CLI Container:
   $ docker stop veil-supra-cli

   Start Supra CLI Container:
   $ docker start veil-supra-cli

   View Container Logs:
   $ docker logs veil-supra-cli

🌐 Network Info:
   • Testnet RPC: https://rpc-testnet.supra.com
   • Testnet Chain ID: 6
   • Testnet Explorer: https://testnet.suprascan.io
   • Testnet Faucet: https://rpc-testnet.supra.com/rpc/v1/wallet/faucet

📝 Contract Locations:
   • VeilHub Package: supra/move_workspace/VeilHub/
   • Veil Testnet Package: supra/veil_testnet/

🚀 Next Steps:

   1. View deployed contracts:
      $ docker exec veil-supra-cli supra move object list \
          --address <YOUR_ACCOUNT_ADDRESS> \
          --rpc-url https://rpc-testnet.supra.com

   2. Deploy more modules:
      $ cd supra/veil_testnet/
      $ docker exec veil-supra-cli supra move tool compile --package-dir /workspace/supra/veil_testnet/
      $ docker exec veil-supra-cli supra move tool publish \
          --package-dir /workspace/supra/veil_testnet/ \
          --rpc-url https://rpc-testnet.supra.com

   3. Create new account:
      $ ./scripts/supra-profile-new.sh

   4. View all profiles:
      $ ./scripts/supra-profile-list.sh

📖 Documentation:
   • QUICKSTART_DEPLOYMENT.md - Full deployment guide
   • SUPRA_CLI_DOCKER.md - Supra CLI reference
   • README.md - Project overview

🔑 Important Notes:
   • Keep your private keys secure (in SUPRA_PRIVATE_KEY)
   • Never commit .env files with sensitive data
   • Testnet funds expire after 7 days of inactivity
   • Always verify contract addresses on explorer before interacting

❓ Need Help?
   • Check documentation in repo root
   • View Supra docs: https://docs.supra.com
   • Visit: https://suprascan.io (mainnet) or https://testnet.suprascan.io (testnet)

═══════════════════════════════════════════════════════════════════════════════

Generated: $(date)
Status: ✅ READY TO DEPLOY

═══════════════════════════════════════════════════════════════════════════════

EOF

################################################################################
# ADDITIONAL HELPFUL COMMANDS
################################################################################

log_section "Quick Reference Commands"

cat << 'EOF'

🔄 CONTAINER MANAGEMENT:
─────────────────────────────────────────────────────────────────────────
# View running containers
docker ps

# Stop container
docker stop veil-supra-cli

# Start container
docker start veil-supra-cli

# Remove container
docker rm veil-supra-cli

# View container logs
docker logs -f veil-supra-cli


📦 MOVE COMPILATION:
─────────────────────────────────────────────────────────────────────────
# Compile VeilHub package
docker exec veil-supra-cli supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub

# Compile Veil Testnet package
docker exec veil-supra-cli supra move tool compile --package-dir /workspace/supra/veil_testnet

# Clean and rebuild
docker exec veil-supra-cli bash -c "cd /workspace/supra/move_workspace/VeilHub && rm -rf build && supra move tool compile --package-dir ."


🚀 DEPLOYMENT:
─────────────────────────────────────────────────────────────────────────
# Publish to testnet
docker exec veil-supra-cli supra move tool publish \
  --package-dir /workspace/supra/move_workspace/VeilHub \
  --rpc-url https://rpc-testnet.supra.com

# Publish to mainnet
docker exec veil-supra-cli supra move tool publish \
  --package-dir /workspace/supra/move_workspace/VeilHub \
  --rpc-url https://rpc-mainnet.supra.com


👤 ACCOUNT MANAGEMENT:
─────────────────────────────────────────────────────────────────────────
# Create new profile
docker exec veil-supra-cli supra move account create --profile-name myprofile

# List all profiles
docker exec veil-supra-cli supra move account list

# Activate profile
docker exec veil-supra-cli supra move account activate --profile-name myprofile

# Get address from profile
docker exec veil-supra-cli supra move account address --profile-name myprofile

# Request testnet funds
docker exec veil-supra-cli supra move account fund-with-faucet \
  --rpc-url https://rpc-testnet.supra.com


🔍 VERIFICATION:
─────────────────────────────────────────────────────────────────────────
# List deployed objects
docker exec veil-supra-cli supra move object list \
  --address YOUR_ADDRESS \
  --rpc-url https://rpc-testnet.supra.com

# Inspect object
docker exec veil-supra-cli supra move object inspect \
  --object-id OBJECT_ID \
  --rpc-url https://rpc-testnet.supra.com

# Get chain info
docker exec veil-supra-cli supra move rpc chain-info \
  --rpc-url https://rpc-testnet.supra.com


🛠️ INTERACTIVE SHELL:
─────────────────────────────────────────────────────────────────────────
# Enter container shell
docker exec -it veil-supra-cli /bin/bash

# Once inside container, you can run supra commands directly:
supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub
supra move account list
supra move account address


═══════════════════════════════════════════════════════════════════════════════

EOF

log_success "Setup script complete!"

echo -e "\n${GREEN}👉 Start with:${NC} cd ~/VeilHubV1 && ./scripts/enter-supra-cli.sh\n"
