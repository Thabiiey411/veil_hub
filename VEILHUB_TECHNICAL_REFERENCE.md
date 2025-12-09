p# 🚀 Veil Hub - Quick Technical Reference

## Module Dependencies Map

```
┌─────────────────────────────────────────────────────────────┐
│                   Entry Points                               │
├─────────────────────────────────────────────────────────────┤
│  veil_token::initialize()                                    │
│  veil_token::mint() / burn()                                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   ┌─────────┐   ┌──────────┐   ┌────────────┐
   │ Lending │   │ Farming  │   │ Treasury   │
   │(5.5% APR)   │(60-80% APY) │(Revenue)    │
   └────┬────┘   └────┬─────┘   └─────┬──────┘
        │             │              │
        ├─────────────┼──────────────┤
        │             │              │
        ▼             ▼              ▼
   ┌──────────────────────────────────────┐
   │    Immortal Reserve (49% APR)        │
   │    └─ Distributes USDC to Holders    │
   └──────────────────────────────────────┘
        │
        ├─ veVEIL (Boost 2.5x)
        ├─ AMM (0.3% fees)
        └─ Router (Multi-hop)
```

---

## Contract Interaction Flow

### **Basic Token Operation**
```move
User → veil_token::mint/burn/transfer → Balance updated → Event emitted
```

### **Lending Flow**
```move
User → debt_engine::borrow(collateral) → Move collateral to vault
                     ↓
            Calculate interest
                     ↓
        User repays principal + interest
                     ↓
        Collateral unlocked + interest sent to treasury
```

### **AMM Swap Flow**
```move
User → amm::swap<X,Y>(amount_in, min_out)
        ↓
    Check pool exists
        ↓
    Calculate output: dy = (y * dx) / (x + dx)
        ↓
    Deduct 0.3% fee: fee = dy * 30 / 10000
        ↓
    Verify dy >= min_out (slippage check)
        ↓
    Transfer X from user, send Y to user
        ↓
    Update reserves: x' = x + dx, y' = y - dy + fee
```

### **Farming Reward Flow**
```move
Week 1: User stakes 1000 LP tokens
             ↓
Week 2: Rewards accrue @ 60% APY = 1.15 VEIL/week
             ↓
User can claim OR auto-compound
             ↓
If claimed: +1.15 VEIL to wallet
If compounded: Stake additional 1.15 LP tokens earned
```

---

## Gas Optimization Tips

| Operation | Gas Cost | Optimization |
|-----------|----------|-------------|
| `initialize()` | High | Called once, no optimization needed |
| `swap()` | Medium | Pre-check min_out to avoid reverts |
| `stake()` | Medium-Low | Batch stakes when possible |
| `claim_rewards()` | Low-Med | Bundle with swaps if possible |
| `liquidate()` | High | Only call when necessary |

---

## Error Codes Reference

### veil_token.move
```move
const E_ZERO_AMOUNT: u64 = 1;           // Amount must be > 0
const E_INSUFFICIENT_BALANCE: u64 = 2;  // Balance too low
const E_EXCEEDS_SUPPLY: u64 = 3;        // Exceeds total supply
const E_BELOW_RESERVE: u64 = 4;         // Below reserve floor (100M)
const E_ALREADY_INITIALIZED: u64 = 5;   // Already initialized
```

### debt_engine.move
```move
const E_ZERO_AMOUNT: u64 = 1;
const E_INSUFFICIENT_COLLATERAL: u64 = 2;  // Not enough collateral
const E_REPAY_EXCEEDS_DEBT: u64 = 3;       // Repaying too much
const E_NO_DEBT: u64 = 4;                  // User has no debt
const E_OVERFLOW: u64 = 5;                 // Math overflow
```

### amm.move
```move
const E_INSUFFICIENT_OUTPUT: u64 = 1;      // Output < min_out
const E_POOL_EXISTS: u64 = 2;              // Pool already exists
const E_ZERO_AMOUNT: u64 = 3;              // Amount is 0
const E_INSUFFICIENT_LIQUIDITY: u64 = 4;   // Pool has < 1000 units
const E_REENTRANCY: u64 = 5;               // Reentrancy detected
const E_SLIPPAGE: u64 = 6;                 // Slippage too high
const E_DIVISION_BY_ZERO: u64 = 7;         // Math error
```

---

## Critical Parameters

### Token
```move
TOTAL_SUPPLY: u64 = 1_000_000_000_00000000  // 1B tokens × 10^8
RESERVE_FLOOR: u64 = 100_000_000_00000000   // 100M (10% protection)
DECIMALS: u8 = 8
```

### Lending
```move
MIN_COLLATERAL_RATIO: u64 = 180             // 180% (1.8x)
LIQUIDATION_RATIO: u64 = 120                // 120% (1.2x)
INTEREST_RATE: u64 = 550                    // 5.5% APR (basis points)
MAX_LEVERAGE: u64 = 5000                    // 50x
```

### AMM
```move
FEE_BPS: u64 = 30                           // 0.3%
MIN_LIQUIDITY: u64 = 1000                   // Minimum pool size
```

### Perpetuals
```move
TRADING_FEE_BPS: u64 = 5                    // 0.05%
MAX_LEVERAGE: u64 = 5000                    // 50x
LIQUIDATION_THRESHOLD: u64 = 9000           // 90%
```

### veVEIL
```move
MIN_LOCK_TIME: u64 = 604800                 // 1 week (seconds)
MAX_LOCK_TIME: u64 = 126144000              // 4 years (seconds)
MIN_BOOST: u64 = 100                        // 1.0x (base)
MAX_BOOST: u64 = 250                        // 2.5x (max lock)
```

---

## Frontend Integration Checklist

### Configuration Files
- [ ] `config/contracts.ts` - Contract addresses
- [ ] `config/wagmi.ts` - Network config
- [ ] `.env.local` - RPC URLs, keys
- [ ] `next.config.js` - Build settings

### Custom Hooks
- [ ] `hooks/supra/useWallet.ts` - Wallet connection
- [ ] `hooks/supra/useVeilToken.ts` - Token operations
- [ ] `hooks/supra/useAMM.ts` - Swap operations
- [ ] `hooks/supra/useFarming.ts` - Staking operations
- [ ] `hooks/supra/useGovernance.ts` - Voting operations

### UI Components
- [ ] `components/Swap.tsx` - Swap interface
- [ ] `components/Farm.tsx` - Farming interface
- [ ] `components/Governance.tsx` - Voting interface
- [ ] `components/Wallet.tsx` - Wallet connection

### Pages
- [ ] `app/page.tsx` - Dashboard
- [ ] `app/swap/page.tsx` - Swap page
- [ ] `app/farm/page.tsx` - Farming page
- [ ] `app/govern/page.tsx` - Governance page

---

## Common Patterns

### Read-Only Queries
```typescript
// Get user balance
const balance = await client.readContract({
  address: VEIL_TOKEN,
  abi: VeilTokenAbi,
  functionName: 'balance_of',
  args: [userAddress],
});

// Get pool reserves
const reserves = await client.readContract({
  address: AMM,
  abi: AmmAbi,
  functionName: 'get_reserves',
  args: ['XType', 'YType'],
});
```

### State-Changing Transactions
```typescript
// Swap tokens
const tx = await client.writeContract({
  address: AMM,
  abi: AmmAbi,
  functionName: 'swap',
  args: [amountIn, minOut, userAddress],
  account: userAccount,
});

// Wait for confirmation
const receipt = await client.waitForTransactionReceipt({ hash: tx });
```

### Error Handling
```typescript
try {
  const result = await executeSwap(amount);
  // Success
} catch (error) {
  if (error.message.includes('E_SLIPPAGE')) {
    // Slippage too high - adjust min_out
  } else if (error.message.includes('E_INSUFFICIENT_LIQUIDITY')) {
    // Pool too small - increase amount
  }
}
```

---

## Testing Commands

### Unit Tests
```bash
cd supra/move_workspace/VeilHub

# Run all tests
supra move test

# Run specific test
supra move test veil_token

# Run with verbose output
supra move test --verbose
```

### Integration Tests
```bash
cd veil-hub-v2

# Frontend tests
npm run test:unit
npm run test:e2e

# Contract tests
npm run test:contracts
```

### Deployment Tests
```bash
# Test on testnet
npm run deploy:testnet

# Verify deployment
npm run verify:contracts

# Run post-deployment checks
npm run test:post-deploy
```

---

## Supra CLI Cheat Sheet

### Wallet Management
```bash
# Create new account
supra key generate

# List accounts
supra key list

# Import account
supra key import <private_key>

# Get account info
supra account <address>
```

### Contract Operations
```bash
# Publish module
supra move publish --package-dir . --url <RPC_URL>

# Call function
supra move run <address>::<module>::<function> --args <args>

# View contract state
supra state <address>::<module>::<struct>

# Check transaction
supra tx <tx_hash>
```

### Network Info
```bash
# Get chain ID
supra chain info

# Get RPC status
curl https://rpc-testnet.supra.com/status

# Get faucet tokens
supra faucet claim <address>
```

---

## Debugging Tips

### Smart Contracts

**Issue: "Pool not found"**
```move
// Solution: Check pool exists before swap
if (!exists<LiquidityPool<X, Y>>(pool_addr)) {
    create_pool<X, Y>(amount_x, amount_y);
}
```

**Issue: "Insufficient liquidity"**
```move
// Solution: Increase min_liquidity or add liquidity first
amm::add_liquidity<X, Y>(amount_x, amount_y);
```

**Issue: "Slippage exceeded"**
```move
// Solution: Recalculate min_out with updated prices
let expected_out = calculate_output(amount_in);
let min_out = (expected_out * 95) / 100;  // 5% slippage
```

### Frontend

**Issue: Wallet not connecting**
```typescript
// Solution: Check network config
const chain = {
  id: 9999,  // Testnet
  name: 'Supra Testnet',
  rpcUrls: {
    default: {
      http: ['https://rpc-testnet.supra.com'],
    },
  },
};
```

**Issue: Transaction failing**
```typescript
// Solution: Check gas estimation
const gasEstimate = await publicClient.estimateContractGas({
  address: contract,
  abi: ABI,
  functionName: 'swap',
  args: [amountIn, minOut],
});
```

---

## Performance Benchmarks

| Operation | Avg Time | Gas Cost |
|-----------|----------|----------|
| Token transfer | 100ms | 21,000 |
| Create pool | 500ms | 150,000 |
| Swap token | 200ms | 50,000 |
| Stake LP | 300ms | 75,000 |
| Claim reward | 400ms | 100,000 |
| Lock VEIL | 250ms | 60,000 |
| Vote | 150ms | 40,000 |

---

## Security Checklist for Deployment

- [ ] All private keys removed from repo
- [ ] Environment variables configured
- [ ] RPC endpoints set to correct network
- [ ] Contract addresses verified
- [ ] ABI files up-to-date
- [ ] Fee parameters reviewed
- [ ] Pause mechanisms tested
- [ ] Emergency withdrawal functions verified
- [ ] Access control roles assigned
- [ ] Event logging working
- [ ] Error handling complete
- [ ] Slippage protection enabled
- [ ] Reentrancy guards active

---

## Production Checklist

### Pre-Launch
- [ ] Contracts audited
- [ ] Frontend security scan passed
- [ ] Load testing completed
- [ ] Mainnet RPC configured
- [ ] Liquidity seeded
- [ ] Marketing ready
- [ ] Support team trained

### Post-Launch
- [ ] Monitor transaction success rate
- [ ] Track TVL growth
- [ ] Monitor gas prices
- [ ] Watch for errors in logs
- [ ] Engagement metrics
- [ ] User feedback collection

---

**Version:** 1.0  
**Last Updated:** December 9, 2025
