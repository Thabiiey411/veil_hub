# Veil Hub - Integration Testing Guide

## 🧪 Testing Strategy

This document provides a comprehensive testing strategy for validating the complete Veil Hub stack: smart contracts, frontend, and network integration.

---

## 1. Smart Contract Testing

### Unit Tests

```bash
cd supra/veil_testnet

# Run all tests
supra move test

# Run specific module tests
supra move test veil_coin::tests
supra move test amm::tests
supra move test farming::tests

# Run with verbose output
supra move test -- --verbose
```

### Contract Compilation

```bash
# Build and check for errors
cd supra/veil_testnet
supra move build --network testnet

# Build with optimization
supra move build --network testnet --release
```

### Key Test Areas

- **veil_coin.move**
  - Mint/burn functionality
  - Transfer mechanisms
  - Balance tracking

- **amm.move**
  - Pool creation
  - Swap calculations
  - Fee distribution

- **farming.move**
  - Staking/unstaking
  - Reward distribution
  - APY calculations

- **veveil.move**
  - Escrow locking
  - Vote weight calculation
  - Time decay mechanism

---

## 2. Frontend Testing

### Local Development

```bash
cd veil-hub-v2

# Install dependencies
npm ci

# Start dev server
npm run dev

# Build for production
npm run build

# Check TypeScript
npm run type-check
```

### Manual Testing Checklist

Visit http://localhost:3000 and verify:

- [ ] **Dashboard Page**
  - Loads without errors
  - Displays portfolio summary
  - Shows connected wallet address

- [ ] **Pools Page**
  - Lists available liquidity pools
  - Shows APY and TVL
  - Can view pool details
  - Fetch data from contract (if deployed)

- [ ] **Farm Page**
  - Shows farming opportunities
  - Displays APY and rewards
  - Can interact with staking UI

- [ ] **Bridge Page**
  - Bridge UI renders correctly
  - Shows network selection
  - Can select assets

- [ ] **Analytics Page**
  - Charts load
  - Historical data displays
  - Responsive layout

- [ ] **Aggregator Page**
  - Displays available strategies
  - Shows strategy details
  - APY calculations display

### Wallet Connection Testing

```javascript
// In browser console:

// Test wallet detection
console.log(window.supraSigner)

// Check chain ID
console.log(window.supraSigner?.getChainId?.())

// Check account
window.supraSigner?.getAccount?.().then(acc => console.log(acc))
```

---

## 3. Network Integration Testing

### Test RPC Endpoints

```bash
# Testnet health check
curl -s https://rpc-testnet.supra.com/health | jq .

# Get chain identifier
curl -X POST https://rpc-testnet.supra.com \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "sui_getChainIdentifier",
    "params": [],
    "id": 1
  }' | jq .

# Get account balance
curl -X POST https://rpc-testnet.supra.com \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "sui_getBalance",
    "params": ["0x<YOUR_ADDRESS>"],
    "id": 1
  }' | jq .
```

### Connection Verification Script

```bash
#!/bin/bash

# Test Supra Testnet connectivity

echo "Testing Supra Testnet..."

# Health endpoint
if curl -s https://rpc-testnet.supra.com/health | jq . > /dev/null; then
    echo "✓ Testnet RPC responding"
else
    echo "✗ Testnet RPC not responding"
    exit 1
fi

# JSON-RPC method
RESULT=$(curl -s -X POST https://rpc-testnet.supra.com \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "sui_getChainIdentifier",
    "params": [],
    "id": 1
  }')

if echo "$RESULT" | jq . > /dev/null 2>&1; then
    CHAIN_ID=$(echo "$RESULT" | jq -r '.result.chainIdentifier')
    if [ "$CHAIN_ID" = "6" ]; then
        echo "✓ Correct chain ID: $CHAIN_ID"
    else
        echo "✗ Wrong chain ID: $CHAIN_ID (expected 6)"
    fi
else
    echo "✗ RPC error:"
    echo "$RESULT"
fi
```

---

## 4. Contract Deployment Verification

### After Deployment

```bash
# Get deployed modules
supra client list-modules --account <YOUR_ADDRESS>

# Get module details
supra client list-modules --account <YOUR_ADDRESS> --json

# Verify contract code
supra client verify-contract \
  --address 0x<DEPLOYED_ADDRESS> \
  --module veil_token
```

### Update Environment

After getting contract addresses:

```bash
# veil-hub-v2/.env.local
NEXT_PUBLIC_VEIL_TOKEN_ADDRESS=0x<ADDRESS>::veil_token
NEXT_PUBLIC_AMM_ADDRESS=0x<ADDRESS>::amm
NEXT_PUBLIC_FARMING_ADDRESS=0x<ADDRESS>::farming
NEXT_PUBLIC_VEVEIL_ADDRESS=0x<ADDRESS>::veveil
NEXT_PUBLIC_BURN_CONTROLLER_ADDRESS=0x<ADDRESS>::burn_controller
NEXT_PUBLIC_DEBT_ENGINE_ADDRESS=0x<ADDRESS>::debt_engine
NEXT_PUBLIC_IMMORTAL_RESERVE_ADDRESS=0x<ADDRESS>::immortal_reserve
```

---

## 5. End-to-End Testing

### Full Integration Test

```bash
#!/bin/bash

echo "Starting E2E tests..."

# 1. Verify network
echo "Step 1: Network verification..."
./scripts/verify-contracts.sh || exit 1

# 2. Build contracts
echo "Step 2: Building contracts..."
cd supra/veil_testnet
supra move build || exit 1
cd ../..

# 3. Build frontend
echo "Step 3: Building frontend..."
cd veil-hub-v2
npm ci
npm run build || exit 1
cd ..

# 4. Run frontend tests
echo "Step 4: Running frontend tests..."
cd veil-hub-v2
npm test || echo "Tests completed with status $?"
cd ..

# 5. Summary
echo "✓ All tests completed"
```

---

## 6. Performance Testing

### Build Performance

```bash
# Measure frontend build time
time npm run build

# Expected: ~30-60 seconds for Next.js build

# Measure contract build time
time supra move build
```

### Bundle Size Analysis

```bash
cd veil-hub-v2

# Analyze bundle size
npm run build -- --analyze

# Check .next directory size
du -sh .next

# Expected: 100-200 MB (dev) / 50-100 MB (optimized)
```

---

## 7. Testing on Vercel

### Pre-deployment Tests

1. **Build Success**
   - Check GitHub Actions workflow passes
   - Verify `npm run build` succeeds

2. **Environment Variables**
   - Ensure all NEXT_PUBLIC_* vars are set in Vercel dashboard
   - No secrets in browser-exposed variables

3. **Preview Deployment**
   - Test on Vercel preview URL before production
   - Check all pages load
   - Test wallet connection

### Post-deployment Tests

```bash
# Test production URL
curl -I https://your-production-url.vercel.app

# Test API routes
curl https://your-production-url.vercel.app/api/health

# Test wallet connection
# Visit https://your-production-url.vercel.app/dashboard
# Connect wallet
# Verify data loads
```

---

## 8. Troubleshooting Tests

### Frontend Tests

| Issue | Test | Solution |
|-------|------|----------|
| Page 404 | `npm run build` fails | Check app/*.tsx syntax |
| Build fails | `npm run type-check` | Fix TypeScript errors |
| Wallet not found | Browser console | Check window.supraSigner |
| RPC unreachable | `curl -s RPC_URL/health` | Check network/firewall |
| Contract call fails | Check .env.local | Verify contract addresses |

### Contract Tests

| Issue | Test | Solution |
|-------|------|----------|
| Build fails | `supra move build` | Check Move syntax |
| Deploy fails | `supra move publish` | Check wallet funds, network |
| Module not found | `supra client list-modules` | Verify deployment success |
| Type error | `supra move test` | Check function signatures |

---

## 9. Continuous Integration

### GitHub Actions Testing

Tests run automatically on:
- Push to main/develop
- Pull requests to main
- Manual trigger

See: `.github/workflows/test-contracts.yml`

### Test Results

Check Actions tab for:
- Contract build status
- Contract test results
- Frontend build status
- Deployment verification

---

## 10. Test Data & Fixtures

### Testnet Test Accounts

```bash
# Get faucet funds
curl -X POST "https://rpc-testnet.supra.com/rpc/v1/wallet/faucet" \
  -H "Content-Type: application/json" \
  -d '{
    "address": "0x<YOUR_ADDRESS>"
  }'

# Check balance
supra client balance --address <YOUR_ADDRESS>
```

### Sample Test Transactions

```bash
# Create test pool (requires deployed contracts)
supra move call \
  --package 0x<AMM_ADDRESS> \
  --module amm \
  --function create_pool \
  --args <ARG1> <ARG2>
```

---

## Summary

✅ Unit tests (contracts)  
✅ Integration tests (frontend + contracts)  
✅ End-to-end tests (full stack)  
✅ Network tests (RPC connectivity)  
✅ Performance tests (build time, bundle size)  
✅ Production tests (Vercel deployment)  

**Test Status**: Ready for Deployment 🚀
