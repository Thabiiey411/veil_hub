╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                  🚀 VEIL HUB V1 - COMPLETE SETUP GUIDES                      ║
║                                                                              ║
║                      Backend Only (No Frontend)                              ║
║                                                                              ║
║                  Clone → Docker → Supra CLI → Deploy Contracts               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

📚 AVAILABLE FILES
═══════════════════════════════════════════════════════════════════════════════

1. 🚀 VEIL_HUB_V1_SETUP.sh (516 lines)
   ├─ Fully automated setup script
   ├─ Handles everything: Docker → Repo → CLI → Deploy
   ├─ Color-coded output and progress tracking
   ├─ Interactive prompts for account setup
   ├─ Error handling and verification steps
   └─ HOW TO USE:
      $ chmod +x VEIL_HUB_V1_SETUP.sh
      $ ./VEIL_HUB_V1_SETUP.sh

   FEATURES:
   ✓ Installs Docker & Docker Compose
   ✓ Clones fresh Veil Hub V1 repo
   ✓ Sets up Supra CLI container
   ✓ Creates and initializes account
   ✓ Compiles Move contracts
   ✓ Deploys to Supra Testnet
   ✓ Verifies deployment
   ✓ Provides quick reference commands


2. 📖 VEIL_HUB_V1_TERMINAL_COMMANDS.md (519 lines)
   ├─ Copy-paste terminal commands (no script required)
   ├─ Step-by-step instructions
   ├─ For manual execution
   ├─ Troubleshooting section
   ├─ Quick reference all commands in order
   └─ HOW TO USE:
      Open in editor and follow each section:
      STEP 1: Install Docker & Docker Compose
      STEP 2: Clone Repository
      STEP 3: Setup Supra CLI
      STEP 4: Initialize Account
      STEP 5: Compile Contracts
      STEP 6: Deploy to Testnet
      STEP 7: Verify Deployment

   SECTIONS:
   ✓ Pre-Requisites
   ✓ Docker installation (Linux & macOS)
   ✓ Repository cloning
   ✓ Supra CLI setup
   ✓ Account initialization
   ✓ Contract compilation
   ✓ Deployment commands
   ✓ Verification steps
   ✓ Container management
   ✓ Account management
   ✓ Network endpoints
   ✓ Project structure
   ✓ Troubleshooting


═══════════════════════════════════════════════════════════════════════════════

🎯 QUICK START
═══════════════════════════════════════════════════════════════════════════════

OPTION 1: Fully Automated (Recommended for beginners)
─────────────────────────────────────────────────────────────────────────────
1. Copy VEIL_HUB_V1_SETUP.sh to your machine
2. Make it executable: chmod +x VEIL_HUB_V1_SETUP.sh
3. Run it: ./VEIL_HUB_V1_SETUP.sh
4. Follow the interactive prompts
5. Wait for completion (5-10 minutes)

Result: Complete Veil Hub V1 setup in ~/VeilHubV1


OPTION 2: Manual Commands (For experienced users)
─────────────────────────────────────────────────────────────────────────────
1. Open VEIL_HUB_V1_TERMINAL_COMMANDS.md
2. Copy commands from each section in order
3. Paste into terminal one section at a time
4. Verify output before proceeding to next section
5. Complete in 10-15 minutes with full understanding

Result: Same setup with more control and learning


═══════════════════════════════════════════════════════════════════════════════

⏱️ ESTIMATED TIME
═══════════════════════════════════════════════════════════════════════════════

Component                    | Time
─────────────────────────────┼──────────────
Docker installation          | 2-5 min
Repository clone             | 1-2 min
Supra CLI Docker setup       | 1-2 min
Account creation & funding   | 2-3 min
Contract compilation         | 2-3 min
Contract deployment          | 2-3 min
─────────────────────────────┼──────────────
TOTAL                        | 12-20 min


═══════════════════════════════════════════════════════════════════════════════

�� WHAT GETS INSTALLED
═══════════════════════════════════════════════════════════════════════════════

✓ Docker & Docker Compose
✓ Git (if not present)
✓ Veil Hub V1 repository (~200MB)
✓ Supra CLI Docker container (~2GB)
✓ Move compiler
✓ 26 smart contract modules
✓ Testnet account with funds


═══════════════════════════════════════════════════════════════════════════════

📊 SYSTEM REQUIREMENTS
═══════════════════════════════════════════════════════════════════════════════

OS:                Linux (Ubuntu/Debian) or macOS
Disk Space:        At least 5GB free
RAM:               4GB minimum (8GB recommended)
Internet:          Required for downloads & testnet
Sudo access:       Required for Docker installation
Commands needed:   git, curl


═══════════════════════════════════════════════════════════════════════════════

🔧 WHAT'S INCLUDED
═══════════════════════════════════════════════════════════════════════════════

Backend Components:
  ✓ 26 Move smart contract modules
  ✓ 8 contract packages (Veil Finance, Yield, Indices, etc.)
  ✓ Docker-based Supra CLI environment
  ✓ Complete deployment automation
  ✓ Contract verification tools
  ✓ Account management scripts
  ✓ Profile management helpers

Deployment Scripts:
  ✓ setup-supra-cli.sh - Install Supra CLI
  ✓ init-supra-account.sh - Create account
  ✓ enter-supra-cli.sh - Open container shell
  ✓ deploy-move.sh - Deploy contracts
  ✓ supra-profile-*.sh - Profile management

Network Support:
  ✓ Supra Testnet (Chain ID: 6)
  ✓ Supra Mainnet (Chain ID: 999)
  ✓ Official faucet integration
  ✓ Explorer links included


═══════════════════════════════════════════════════════════════════════════════

❌ WHAT'S NOT INCLUDED
═══════════════════════════════════════════════════════════════════════════════

✗ Frontend (Next.js) - Backend only
✗ Web3 wallet integration
✗ Vercel deployment
✗ CI/CD pipelines (GitHub Actions template provided separately)


═══════════════════════════════════════════════════════════════════════════════

🌐 NETWORK ENDPOINTS
═══════════════════════════════════════════════════════════════════════════════

Testnet:
  RPC: https://rpc-testnet.supra.com
  Chain ID: 6
  Explorer: https://testnet.suprascan.io
  Faucet: https://rpc-testnet.supra.com/rpc/v1/wallet/faucet

Mainnet:
  RPC: https://rpc-mainnet.supra.com
  Chain ID: 999
  Explorer: https://suprascan.io


═══════════════════════════════════════════════════════════════════════════════

📁 FINAL DIRECTORY STRUCTURE
═══════════════════════════════════════════════════════════════════════════════

~/VeilHubV1/
├── supra/
│   ├── move_workspace/
│   │   └── VeilHub/
│   │       ├── sources/          (Contract code)
│   │       ├── Move.toml
│   │       └── build/            (Compiled output)
│   └── veil_testnet/
│       ├── sources/
│       ├── Move.toml
│       └── build/
├── scripts/
│   ├── setup-supra-cli.sh
│   ├── init-supra-account.sh
│   ├── enter-supra-cli.sh
│   ├── deploy-move.sh
│   ├── supra-profile-*.sh
│   └── ...
├── .github/workflows/
│   └── deploy-move.yml           (CI/CD template)
├── QUICKSTART_DEPLOYMENT.md
├── SUPRA_CLI_DOCKER.md
├── README.md
└── ... (other documentation)


═══════════════════════════════════════════════════════════════════════════════

💡 TIPS & TRICKS
═══════════════════════════════════════════════════════════════════════════════

TIP 1: Keep Docker running
  → Even after setup, keep the container running for future deployments
  → Start with: docker start veil-supra-cli

TIP 2: Multiple accounts
  → Create different accounts for testing
  → Each account needs separate testnet funding

TIP 3: Watch container logs
  → docker logs -f veil-supra-cli
  → Useful for debugging deployment issues

TIP 4: Interactive shell access
  → docker exec -it veil-supra-cli /bin/bash
  → Run Supra commands directly inside container

TIP 5: Save your addresses
  → Copy deployed contract addresses to a file
  → You'll need them for frontend integration later

TIP 6: Check testnet funds
  → Testnet funds expire after 7 days
  → Request new funds if account runs out

TIP 7: Verify on explorer
  → Always check https://testnet.suprascan.io
  → Confirm contracts deployed correctly
  → View transaction history


═══════════════════════════════════════════════════════════════════════════════

❓ COMMON QUESTIONS
═══════════════════════════════════════════════════════════════════════════════

Q: Can I run this on Windows?
A: Not directly. Use WSL2 (Windows Subsystem for Linux 2) or Docker Desktop for Windows.

Q: Do I need Supra mainnet deployed right now?
A: No. Start with testnet. Deploy to mainnet when ready.

Q: Can I change the deployment directory?
A: Yes. Edit REPO_DIR variable in VEIL_HUB_V1_SETUP.sh or use different paths in manual commands.

Q: What if Docker installation fails?
A: Check Docker docs for your OS. Use manual commands if needed.

Q: How do I backup my account?
A: Account/profiles are in ~/.supra/. Back up this directory.

Q: Can I deploy multiple contracts?
A: Yes. VeilHub + VeilTestnet are included. Deploy both.

Q: What's the cost of deployment?
A: Testnet is free. Mainnet requires gas fees in SUPRA tokens.


═══════════════════════════════════════════════════════════════════════════════

🆘 TROUBLESHOOTING
═══════════════════════════════════════════════════════════════════════════════

Issue: Docker command not found
  → Install Docker: https://docs.docker.com/get-docker/

Issue: Permission denied (docker)
  → Run: sudo usermod -aG docker $USER
  → Then logout and login

Issue: Container won't start
  → Check logs: docker logs veil-supra-cli
  → Verify Docker daemon: docker ps
  → Restart: docker restart veil-supra-cli

Issue: Insufficient funds
  → Request more: docker exec veil-supra-cli supra move account fund-with-faucet --rpc-url https://rpc-testnet.supra.com

Issue: Compilation fails
  → Clean build: rm -rf supra/move_workspace/VeilHub/build
  → Try again: supra move tool compile

Issue: Account not found
  → List accounts: docker exec veil-supra-cli supra move account list
  → Create new: docker exec veil-supra-cli supra move account create --profile-name newaccount

See VEIL_HUB_V1_TERMINAL_COMMANDS.md for more detailed troubleshooting.


═══════════════════════════════════════════════════════════════════════════════

📚 ADDITIONAL RESOURCES
═══════════════════════════════════════════════════════════════════════════════

Official Documentation:
  • Supra Docs: https://docs.supra.com
  • Move Language: https://docs.supra.com/move
  • Supra Explorer: https://testnet.suprascan.io / https://suprascan.io
  • GitHub: https://github.com/Thabiiey411

Community:
  • Discord: https://discord.gg/supra
  • Telegram: https://t.me/supracommunity


═══════════════════════════════════════════════════════════════════════════════

✅ SUCCESS VERIFICATION
═══════════════════════════════════════════════════════════════════════════════

After running either setup, verify success:

1. Docker installed:
   $ docker --version

2. Repository cloned:
   $ ls ~/VeilHubV1

3. Container running:
   $ docker ps | grep veil-supra-cli

4. Account created:
   $ docker exec veil-supra-cli supra move account list

5. Contracts deployed:
   $ docker exec veil-supra-cli supra move object list --address <YOUR_ADDRESS> --rpc-url https://rpc-testnet.supra.com

6. Explorer verification:
   Visit: https://testnet.suprascan.io/account/<YOUR_ADDRESS>

If all steps show success, you're ready! 🎉


═══════════════════════════════════════════════════════════════════════════════

Generated: December 8, 2025
Status: ✅ Production Ready
Backend: ✅ Complete (26 modules)
Frontend: ❌ Not included (use veil_hub2 repo)

═══════════════════════════════════════════════════════════════════════════════
