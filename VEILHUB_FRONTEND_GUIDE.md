# 🎨 Veil Hub - Frontend Startup Guide

**Status:** Production Ready  
**Framework:** Next.js 14  
**Styling:** Tailwind CSS  
**Blockchain:** Supra L1

---

## 📦 Project Structure

```
veil-hub-v2/
├── app/                          # Next.js app directory
│   ├── layout.tsx               # Root layout
│   ├── page.tsx                 # Dashboard home
│   ├── globals.css              # Global styles
│   ├── providers.tsx            # Context providers
│   ├── aggregator/              # Yield aggregator pages
│   ├── analytics/               # Analytics dashboard
│   ├── bridge/                  # Bridge interface
│   ├── dashboard/               # Main dashboard
│   ├── farm/                    # Farming interface
│   ├── pools/                   # Liquidity pools
│   └── veil-hub/                # Hub features
├── components/                   # Reusable React components
│   ├── aggregator/              # Aggregator UI components
│   ├── bridge/                  # Bridge UI components
│   ├── farm/                    # Farm UI components
│   ├── layout/                  # Layout components (Header, Footer, Sidebar)
│   └── pools/                   # Pool UI components
├── hooks/                        # Custom React hooks
│   ├── supra/                   # Supra blockchain hooks
│   │   ├── useWallet.ts         # Wallet connection
│   │   ├── useVeilToken.ts      # Token operations
│   │   ├── useAMM.ts            # Swap/liquidity
│   │   ├── useFarming.ts        # Staking
│   │   ├── useGovernance.ts     # Voting
│   │   ├── usePerpetual.ts      # Perpetuals
│   │   └── useSmartContracts.ts # Generic contract calls
│   └── useTheme.ts              # Theme management
├── lib/                          # Utility functions
│   ├── supra-contracts.ts       # Contract interfaces
│   ├── utils.ts                 # Helper functions
│   └── constants.ts             # App constants
├── config/                       # Configuration
│   ├── contracts.ts             # Contract addresses
│   ├── wagmi.ts                 # Web3 config
│   ├── supra-addresses.json     # Supra contract addresses
│   └── networks.ts              # Network configs
├── public/                       # Static assets
│   ├── icons/
│   ├── images/
│   └── logos/
├── docs/                         # Documentation
│   ├── COMPETITIVE-EDGE.md
│   ├── SECURITY.md
│   ├── UNIFIED-TOKENOMICS-V17.md
│   └── ...
├── scripts/                      # Build/deploy scripts
├── package.json                  # Dependencies
├── tsconfig.json                 # TypeScript config
├── tailwind.config.ts            # Tailwind config
├── next.config.js                # Next.js config
├── postcss.config.js             # PostCSS config
└── README.md
```

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd veil-hub-v2
npm install
# or
yarn install
# or
pnpm install
```

### 2. Configure Environment
Create `.env.local`:
```bash
# Supra Network
NEXT_PUBLIC_SUPRA_RPC_TESTNET="https://rpc-testnet.supra.com"
NEXT_PUBLIC_SUPRA_RPC_MAINNET="https://rpc-mainnet.supra.com"
NEXT_PUBLIC_SUPRA_CHAIN_ID_TESTNET="9999"
NEXT_PUBLIC_SUPRA_CHAIN_ID_MAINNET="6"

# Contract Addresses (update after deployment)
NEXT_PUBLIC_VEIL_TOKEN="0xf268...::veil_token"
NEXT_PUBLIC_AMM="0xf268...::amm"
NEXT_PUBLIC_FARMING="0xf268...::farming"
NEXT_PUBLIC_PERPETUAL_DEX="0xf268...::perpetual_dex"
NEXT_PUBLIC_IMMORTAL_RESERVE="0xf268...::immortal_reserve"
NEXT_PUBLIC_VEVEIL="0xf268...::veveil"

# Feature flags
NEXT_PUBLIC_ENABLE_PERPETUALS="true"
NEXT_PUBLIC_ENABLE_GOVERNANCE="true"
NEXT_PUBLIC_ENABLE_BRIDGE="false"
NEXT_PUBLIC_ENABLE_ANALYTICS="true"

# Analytics (optional)
NEXT_PUBLIC_GA_ID="G_XXXXXX"
```

### 3. Run Development Server
```bash
npm run dev
# Open http://localhost:3000
```

### 4. Build for Production
```bash
npm run build
npm run start
```

---

## 📚 Component Guide

### Dashboard (`app/page.tsx`)

**Features:**
- Portfolio overview
- Total TVL display
- User positions summary
- Quick action buttons

**Key Sections:**
```tsx
export function Dashboard() {
  return (
    <>
      <header>Portfolio Overview</header>
      <section>Total Value Locked</section>
      <section>Your Positions</section>
      <section>Quick Actions</section>
    </>
  );
}
```

---

### Swap Interface (`app/aggregator/page.tsx`)

**Features:**
- Token pair selection
- Price quotes
- Slippage settings
- Transaction preview

**User Flow:**
```
1. Select "From" token (e.g., USDC)
2. Select "To" token (e.g., VEIL)
3. Enter amount
4. View price impact & fees
5. Review slippage tolerance
6. Click "Swap"
7. Sign transaction
8. Confirm completion
```

**Component Structure:**
```tsx
<SwapContainer>
  <TokenSelector from={token} />
  <PriceDisplay price={quote} />
  <SlippageSettings tolerance={0.5} />
  <SwapButton onClick={handleSwap} />
</SwapContainer>
```

---

### Farming Interface (`app/farm/page.tsx`)

**Features:**
- LP token staking
- Reward tracking
- APY display
- Claim/compound buttons

**User Flow:**
```
1. Select LP token pair
2. View current APY (base + boost)
3. Enter stake amount
4. Approve token spending
5. Click "Stake"
6. View pending rewards
7. Claim or auto-compound rewards
```

**APY Calculation UI:**
```tsx
<APYDisplay>
  <BaseAPY>{baseAPY}%</BaseAPY>
  <Boost>{boost}x</Boost>
  <TotalAPY>{totalAPY}%</TotalAPY>
</APYDisplay>
```

---

### Governance (`app/veil-hub/page.tsx`)

**Features:**
- Lock VEIL for veVEIL
- View voting power
- Vote on proposals
- Claim governance rewards

**Lock Duration → Boost:**
| Duration | Boost | Example |
|----------|-------|---------|
| 1 week | 1.0x | 1,000 VEIL → 1,000 veVEIL |
| 6 months | 1.5x | 1,000 VEIL → 1,500 veVEIL |
| 1 year | 2.0x | 1,000 VEIL → 2,000 veVEIL |
| 4 years | 2.5x | 1,000 VEIL → 2,500 veVEIL |

**Component:**
```tsx
<GovernanceCard>
  <LockDurationSlider onChange={setDuration} />
  <BoostIndicator duration={duration} />
  <LockButton onClick={handleLock} />
</GovernanceCard>
```

---

### Perpetuals (`app/pools/page.tsx` - if enabled)

**Features:**
- Open long/short positions
- Leverage selection (1x-50x)
- Liquidation price display
- Position management

**Position Flow:**
```
1. Select asset (BTC, ETH, SOL)
2. Choose direction (Long/Short)
3. Enter collateral amount
4. Select leverage (1x-50x)
5. View liquidation price
6. Open position
7. Manage position (adjust, close, TP/SL)
```

---

## 🔧 Custom Hooks

### `useVeilToken()`

**Purpose:** Token operations

```typescript
const {
  balance,          // User's VEIL balance
  totalSupply,      // Total VEIL supply
  mint,             // Mint tokens (admin)
  burn,             // Burn tokens
  transfer,         // Transfer tokens
  approve,          // Approve spending
  allowance,        // Check allowance
  loading,          // Loading state
  error,            // Error message
  refetch,          // Refresh data
} = useVeilToken(userAddress);

// Usage
const handleTransfer = async () => {
  await transfer('0x...recipient', 100);
  refetch();
};
```

---

### `useAMM()`

**Purpose:** Liquidity & swap operations

```typescript
const {
  pools,            // Available pools
  reserves,         // Pool reserves
  quote,            // Price quote
  swap,             // Execute swap
  addLiquidity,     // Add liquidity
  removeLiquidity,  // Remove liquidity
  loading,
  error,
} = useAMM();

// Usage
const handleSwap = async () => {
  const amountOut = await quote(amountIn);
  const minOut = (amountOut * 95) / 100;  // 5% slippage
  await swap(amountIn, minOut);
};
```

---

### `useFarming()`

**Purpose:** Staking & rewards

```typescript
const {
  stakedAmount,     // User's staked LP
  pendingRewards,   // Unclaimed rewards
  apy,              // Current APY
  stakedApy,        // With boost
  stake,            // Stake LP tokens
  unstake,          // Unstake LP tokens
  claimRewards,     // Claim rewards
  compound,         // Auto-compound
  loading,
} = useFarming(userAddress);

// Usage
const handleCompound = async () => {
  await compound();
  await refetch();
};
```

---

### `useGovernance()`

**Purpose:** Voting & governance

```typescript
const {
  veVeilBalance,    // User's veVEIL
  votingPower,      // Total voting power
  proposals,        // Active proposals
  lockDuration,     // Current lock period
  lock,             // Lock VEIL
  unlock,           // Unlock VEIL
  vote,             // Vote on proposal
  delegate,         // Delegate votes
  loading,
} = useGovernance(userAddress);

// Usage
const handleLock = async (amount, duration) => {
  await lock(amount, duration);
  // User now has veVEIL = amount × boost(duration)
};
```

---

### `useWallet()`

**Purpose:** Wallet connection

```typescript
const {
  address,          // Connected wallet address
  isConnected,      // Connection status
  network,          // Current network
  balance,          // Native balance
  connect,          // Connect wallet
  disconnect,       // Disconnect wallet
  switchNetwork,    // Change network
} = useWallet();

// Usage
const handleConnect = async () => {
  await connect();
  if (network.id !== SUPRA_TESTNET_ID) {
    await switchNetwork(SUPRA_TESTNET_ID);
  }
};
```

---

## 🎨 Styling Guide

### Tailwind Configuration

Key breakpoints:
```typescript
screens: {
  'sm': '640px',    // Mobile
  'md': '768px',    // Tablet
  'lg': '1024px',   // Desktop
  'xl': '1280px',   // Wide
  '2xl': '1536px',  // Ultra-wide
}
```

### Color Palette

**Primary Colors:**
```css
primary: {
  50: '#f9f5ff',
  500: '#7c3aed',   /* Indigo */
  900: '#3730a3',
}

secondary: {
  50: '#f0f9ff',
  500: '#0ea5e9',   /* Cyan */
  900: '#0c4a6e',
}

accent: {
  500: '#ec4899',   /* Pink */
}
```

**Semantic Colors:**
```css
success: '#10b981'   /* Green */
warning: '#f59e0b'   /* Amber */
danger: '#ef4444'    /* Red */
info: '#3b82f6'      /* Blue */
```

---

## 🔌 Contract Integration

### Example: Swap Integration

```typescript
// 1. Get quote
const quote = async (amountIn: number) => {
  const result = await publicClient.call({
    account: userAddress,
    address: AmmAddress,
    abi: AmmABI,
    functionName: 'quote_swap',
    args: ['USDC', 'VEIL', BigInt(amountIn)],
  });
  return Number(result);
};

// 2. Execute swap
const executeSwap = async (amountIn: number) => {
  const amountOut = await quote(amountIn);
  const minOut = BigInt((amountOut * 95) / 100); // 5% slippage
  
  const tx = await walletClient.writeContract({
    address: AmmAddress,
    abi: AmmABI,
    functionName: 'swap_exact_in',
    args: [
      BigInt(amountIn),
      minOut,
      userAddress,
    ],
  });
  
  return tx;
};

// 3. Update UI
const handleSwap = async () => {
  setLoading(true);
  try {
    const tx = await executeSwap(amount);
    await publicClient.waitForTransactionReceipt({ hash: tx });
    await refetchBalance();
    setAmount('');
  } catch (error) {
    setError(error.message);
  } finally {
    setLoading(false);
  }
};
```

---

## 📊 Analytics Integration

### Event Tracking

```typescript
// Track swap
analytics.track('Swap', {
  from: 'USDC',
  to: 'VEIL',
  amount: 1000,
  amountOut: 33333,
  fee: 100,
  timestamp: Date.now(),
});

// Track farming
analytics.track('Stake', {
  amount: 100,
  token: 'VEIL-ETH LP',
  apy: 65.5,
  boost: 1.5,
  timestamp: Date.now(),
});

// Track governance
analytics.track('Vote', {
  proposal: 'Increase farming rewards',
  choice: 'For',
  power: 2500,
  timestamp: Date.now(),
});
```

---

## 🧪 Testing

### Unit Tests

```typescript
// Example: useVeilToken hook test
describe('useVeilToken', () => {
  it('should fetch balance', async () => {
    const { result } = renderHook(() => useVeilToken(address));
    
    await waitFor(() => {
      expect(result.current.balance).toBe(1000);
    });
  });

  it('should transfer tokens', async () => {
    const { result } = renderHook(() => useVeilToken(address));
    
    await result.current.transfer('0x...', 100);
    
    expect(result.current.balance).toBe(900);
  });
});
```

### E2E Tests

```typescript
// Example: Swap flow test
describe('Swap Flow', () => {
  it('should complete swap from start to finish', async () => {
    // 1. Connect wallet
    await page.click('[data-test="connect-wallet"]');
    
    // 2. Navigate to swap
    await page.click('[data-test="nav-swap"]');
    
    // 3. Select tokens
    await page.click('[data-test="from-token"]');
    await page.click('[data-test="token-usdc"]');
    
    // 4. Enter amount
    await page.fill('[data-test="amount-input"]', '100');
    
    // 5. Execute swap
    await page.click('[data-test="swap-button"]');
    
    // 6. Confirm
    await page.click('[data-test="confirm-button"]');
    
    // 7. Wait for success
    await page.waitForSelector('[data-test="swap-success"]');
  });
});
```

---

## 🚀 Deployment

### Vercel Deployment

1. **Connect Repository**
```bash
vercel link
```

2. **Configure Environment**
```bash
vercel env add NEXT_PUBLIC_SUPRA_RPC_TESTNET
vercel env add NEXT_PUBLIC_VEIL_TOKEN
# ... add other variables
```

3. **Deploy**
```bash
vercel --prod
```

### Self-Hosted Deployment

1. **Build**
```bash
npm run build
npm run start
```

2. **Docker**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY .next ./
EXPOSE 3000
CMD ["npm", "start"]
```

3. **Docker Compose**
```bash
docker-compose up -d
```

---

## 📱 Mobile Optimization

### Responsive Design

```typescript
// Mobile-first approach
export const MobileMenu = () => {
  return (
    <>
      {/* Hidden on desktop */}
      <div className="md:hidden">
        <MobileNav />
      </div>

      {/* Hidden on mobile */}
      <div className="hidden md:block">
        <DesktopNav />
      </div>
    </>
  );
};
```

### Touch Interactions

```typescript
// Better touch targets
export const TouchButton = styled.button`
  min-height: 44px;  /* iOS recommendation */
  min-width: 44px;
  padding: 12px 16px;
  
  @media (hover: hover) {
    &:hover {
      background: var(--hover-color);
    }
  }
`;
```

---

## 🔒 Security Best Practices

### Private Key Management
- ✅ Use wallet providers (Phantom, Core)
- ✅ Never store keys in frontend
- ✅ Use environment variables for RPC URLs

### Transaction Security
- ✅ Always verify contract addresses
- ✅ Implement slippage protection
- ✅ Add transaction timeout limits
- ✅ Require user confirmation before signing

### Data Validation
- ✅ Validate all user inputs
- ✅ Sanitize blockchain data
- ✅ Use TypeScript for type safety

---

## 🐛 Troubleshooting

### "Wallet not connecting"
```typescript
// Check network configuration
const isCorrectNetwork = network.id === SUPRA_TESTNET_ID;
if (!isCorrectNetwork) {
  await switchNetwork(SUPRA_TESTNET_ID);
}
```

### "Transaction failed"
```typescript
// Add error handling
try {
  const tx = await executeTransaction();
} catch (error) {
  if (error.message.includes('insufficient balance')) {
    showError('Insufficient balance');
  } else if (error.message.includes('revert')) {
    showError('Transaction reverted');
  }
}
```

### "Quote out of date"
```typescript
// Refresh quote periodically
useEffect(() => {
  const interval = setInterval(refetchQuote, 10000); // 10 seconds
  return () => clearInterval(interval);
}, [refetchQuote]);
```

---

## 📚 Useful Resources

**Documentation:**
- 📖 Next.js: https://nextjs.org/docs
- 🎨 Tailwind: https://tailwindcss.com/docs
- ⛓️ Supra Docs: https://docs.supra.com
- 🔗 wagmi: https://wagmi.sh

**Tools:**
- 🔍 Supra Explorer: https://testnet.suprascan.io
- 💻 Console: https://console.supra.com
- 🧪 Supra CLI: `npm install -g supra-cli`

---

**Version:** 1.0  
**Last Updated:** December 9, 2025  
**Framework:** Next.js 14 + Tailwind CSS
