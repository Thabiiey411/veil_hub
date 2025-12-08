/// Automated Market Maker (AMM) - 0.3% fee, constant product formula
module veil_finance::amm {
    use std::signer;

    struct Pool<phantom X, phantom Y> has key {
        reserve_x: u64,
        reserve_y: u64,
        lp_supply: u64,
        collected_fees_x: u64,
        collected_fees_y: u64,
    }

    struct LPCoin<phantom X, phantom Y> has key {
        amount: u64,
    }

    const FEE_BPS: u64 = 30; // 0.3% fee
    const MIN_LIQUIDITY: u64 = 1000;

    const E_INSUFFICIENT_LIQUIDITY: u64 = 1;
    const E_INVALID_AMOUNTS: u64 = 2;
    const E_INSUFFICIENT_OUTPUT: u64 = 3;
    const E_POOL_EXISTS: u64 = 4;
    const E_ZERO_AMOUNT: u64 = 5;

    /// Create a new liquidity pool
    public entry fun create_pool<X, Y>(creator: &signer, amount_x: u64, amount_y: u64) {
        let addr = signer::address_of(creator);
        assert!(amount_x > 0 && amount_y > 0, E_INVALID_AMOUNTS);
        assert!(amount_x >= MIN_LIQUIDITY && amount_y >= MIN_LIQUIDITY, E_INSUFFICIENT_LIQUIDITY);

        move_to(creator, Pool<X, Y> {
            reserve_x: amount_x,
            reserve_y: amount_y,
            lp_supply: sqrt(amount_x * amount_y),
            collected_fees_x: 0,
            collected_fees_y: 0,
        });
    }

    /// Add liquidity to an existing pool
    public fun add_liquidity<X, Y>(
        user: &signer,
        amount_x: u64,
        amount_y: u64,
    ): u64 acquires Pool {
        assert!(amount_x > 0 && amount_y > 0, E_INVALID_AMOUNTS);

        let pool = borrow_global_mut<Pool<X, Y>>(@veil_finance);
        let reserve_x = pool.reserve_x;
        let reserve_y = pool.reserve_y;

        // Calculate LP tokens to mint
        let liquidity_x = (amount_x * pool.lp_supply) / reserve_x;
        let liquidity_y = (amount_y * pool.lp_supply) / reserve_y;
        let lp_tokens = if (liquidity_x < liquidity_y) { liquidity_x } else { liquidity_y };

        pool.reserve_x = pool.reserve_x + amount_x;
        pool.reserve_y = pool.reserve_y + amount_y;
        pool.lp_supply = pool.lp_supply + lp_tokens;

        lp_tokens
    }

    /// Remove liquidity from pool
    public fun remove_liquidity<X, Y>(
        user: &signer,
        lp_tokens: u64,
    ): (u64, u64) acquires Pool {
        assert!(lp_tokens > 0, E_ZERO_AMOUNT);

        let pool = borrow_global_mut<Pool<X, Y>>(@veil_finance);
        let amount_x = (lp_tokens * pool.reserve_x) / pool.lp_supply;
        let amount_y = (lp_tokens * pool.reserve_y) / pool.lp_supply;

        pool.reserve_x = pool.reserve_x - amount_x;
        pool.reserve_y = pool.reserve_y - amount_y;
        pool.lp_supply = pool.lp_supply - lp_tokens;

        (amount_x, amount_y)
    }

    /// Swap X for Y
    public fun swap_x_for_y<X, Y>(user: &signer, amount_in: u64): u64 acquires Pool {
        assert!(amount_in > 0, E_ZERO_AMOUNT);

        let pool = borrow_global_mut<Pool<X, Y>>(@veil_finance);
        let fee = (amount_in * FEE_BPS) / 10000;
        let amount_in_after_fee = amount_in - fee;

        let numerator = amount_in_after_fee * pool.reserve_y;
        let denominator = pool.reserve_x + amount_in_after_fee;
        let amount_out = numerator / denominator;

        assert!(amount_out > 0, E_INSUFFICIENT_OUTPUT);

        pool.reserve_x = pool.reserve_x + amount_in_after_fee;
        pool.reserve_y = pool.reserve_y - amount_out;
        pool.collected_fees_x = pool.collected_fees_x + fee;

        amount_out
    }

    /// Swap Y for X
    public fun swap_y_for_x<X, Y>(user: &signer, amount_in: u64): u64 acquires Pool {
        assert!(amount_in > 0, E_ZERO_AMOUNT);

        let pool = borrow_global_mut<Pool<X, Y>>(@veil_finance);
        let fee = (amount_in * FEE_BPS) / 10000;
        let amount_in_after_fee = amount_in - fee;

        let numerator = amount_in_after_fee * pool.reserve_x;
        let denominator = pool.reserve_y + amount_in_after_fee;
        let amount_out = numerator / denominator;

        assert!(amount_out > 0, E_INSUFFICIENT_OUTPUT);

        pool.reserve_y = pool.reserve_y + amount_in_after_fee;
        pool.reserve_x = pool.reserve_x - amount_out;
        pool.collected_fees_y = pool.collected_fees_y + fee;

        amount_out
    }

    /// Get pool reserves
    public fun get_reserves<X, Y>(): (u64, u64) acquires Pool {
        let pool = borrow_global<Pool<X, Y>>(@veil_finance);
        (pool.reserve_x, pool.reserve_y)
    }

    /// Get LP supply
    public fun get_lp_supply<X, Y>(): u64 acquires Pool {
        borrow_global<Pool<X, Y>>(@veil_finance).lp_supply
    }

    /// Integer square root function
    fun sqrt(n: u64): u64 {
        if (n == 0) {
            return 0
        };
        let x = n;
        let y = (x + 1) / 2;
        while (y < x) {
            x = y;
            y = (x + n / x) / 2;
        };
        x
    }
}
