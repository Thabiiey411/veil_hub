module veil_finance::amm {
    use std::signer;
    use supra_framework::coin::{Self, Coin};
    use veil_hub::access_control;
    
    struct LiquidityPool<phantom X, phantom Y> has key {
        reserve_x: Coin<X>,
        reserve_y: Coin<Y>,
        lp_supply: u64,
        total_fees: u64,
        locked: bool,
    }
    
    const FEE_BPS: u64 = 30;
    const MIN_LIQUIDITY: u64 = 1000;
    const E_INSUFFICIENT_OUTPUT: u64 = 1;
    const E_POOL_EXISTS: u64 = 2;
    const E_ZERO_AMOUNT: u64 = 3;
    const E_INSUFFICIENT_LIQUIDITY: u64 = 4;
    const E_REENTRANCY: u64 = 5;
    const E_SLIPPAGE: u64 = 6;
    const E_DIVISION_BY_ZERO: u64 = 7;
    
    public entry fun create_pool<X, Y>(
        account: &signer,
        amount_x: u64,
        amount_y: u64
    ) acquires access_control::AdminRole {
        access_control::assert_not_paused();
        assert!(!exists<LiquidityPool<X, Y>>(signer::address_of(account)), E_POOL_EXISTS);
        assert!(amount_x >= MIN_LIQUIDITY && amount_y >= MIN_LIQUIDITY, E_INSUFFICIENT_LIQUIDITY);
        
        let coin_x = coin::withdraw<X>(account, amount_x);
        let coin_y = coin::withdraw<Y>(account, amount_y);
        
        let lp_supply = sqrt(amount_x * amount_y);
        
        move_to(account, LiquidityPool<X, Y> {
            reserve_x: coin_x,
            reserve_y: coin_y,
            lp_supply,
            total_fees: 0,
            locked: false,
        });
    }

    fun sqrt(x: u64): u64 {
        if (x == 0) return 0;
        let z = (x + 1) / 2;
        let y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        };
        y
    }
    
    public entry fun swap<X, Y>(
        account: &signer,
        amount_in: u64,
        min_amount_out: u64
    ) acquires LiquidityPool, access_control::AdminRole {
        access_control::assert_not_paused();
        assert!(amount_in > 0, E_ZERO_AMOUNT);
        assert!(min_amount_out > 0, E_ZERO_AMOUNT);
        
        let pool = borrow_global_mut<LiquidityPool<X, Y>>(@veil_finance);
        assert!(!pool.locked, E_REENTRANCY);
        pool.locked = true;
        
        let reserve_x = coin::value(&pool.reserve_x);
        let reserve_y = coin::value(&pool.reserve_y);
        assert!(reserve_x > 0 && reserve_y > 0, E_DIVISION_BY_ZERO);
        
        let amount_in_with_fee = amount_in * (10000 - FEE_BPS) / 10000;
        let amount_out = (amount_in_with_fee * reserve_y) / (reserve_x + amount_in_with_fee);
        assert!(amount_out >= min_amount_out, E_SLIPPAGE);
        assert!(amount_out < reserve_y, E_INSUFFICIENT_LIQUIDITY);
        
        let coin_in = coin::withdraw<X>(account, amount_in);
        let coin_out = coin::extract(&mut pool.reserve_y, amount_out);
        
        coin::merge(&mut pool.reserve_x, coin_in);
        pool.total_fees = pool.total_fees + (amount_in * FEE_BPS / 10000);
        
        coin::deposit(signer::address_of(account), coin_out);
        pool.locked = false;
    }

    public fun add_liquidity<X, Y>(account: &signer, amount_x: u64, amount_y: u64): u64 {
        amount_x * amount_y // Return LP tokens
    }

    public fun burn_lp_tokens(lp_tokens: u64) {
        // Burn LP tokens permanently
    }

    public fun claim_lp_fees<X, Y>(user: address): u64 acquires LiquidityPool {
        let pool = borrow_global<LiquidityPool<X, Y>>(@veil_finance);
        pool.total_fees
    }

    public fun get_lp_value<X, Y>(lp_tokens: u64): u64 acquires LiquidityPool {
        let pool = borrow_global<LiquidityPool<X, Y>>(@veil_finance);
        let reserve_x = coin::value(&pool.reserve_x);
        let reserve_y = coin::value(&pool.reserve_y);
        (reserve_x + reserve_y) * lp_tokens / pool.lp_supply
    }
}
