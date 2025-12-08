module veil_finance::lp_vacuum {
    use supra_framework::coin::{Self, Coin};
    use supra_framework::signer;
    use veil_finance::amm;
    use governance::treasury;

    const VACUUM_FEE_BPS: u64 = 50; // 0.5%
    const E_INSUFFICIENT_AMOUNT: u64 = 1;

    struct VacuumStats has key {
        total_vacuumed: u64,
        total_fees: u64,
        vacuum_count: u64
    }

    public entry fun vacuum_liquidity<TokenA, TokenB>(
        account: &signer,
        amount_a: u64,
        amount_b: u64
    ) {
        assert!(amount_a > 0 && amount_b > 0, E_INSUFFICIENT_AMOUNT);
        
        let fee_a = amount_a * VACUUM_FEE_BPS / 10000;
        let fee_b = amount_b * VACUUM_FEE_BPS / 10000;
        
        let lp_tokens = amm::add_liquidity<TokenA, TokenB>(
            account,
            amount_a - fee_a,
            amount_b - fee_b
        );
        
        amm::burn_lp_tokens(lp_tokens);
        treasury::deposit_vacuum_fee(fee_a + fee_b);
        
        update_stats(amount_a + amount_b, fee_a + fee_b);
    }

    fun update_stats(vacuumed: u64, fees: u64) acquires VacuumStats {
        let stats = borrow_global_mut<VacuumStats>(@veil_finance);
        stats.total_vacuumed = stats.total_vacuumed + vacuumed;
        stats.total_fees = stats.total_fees + fees;
        stats.vacuum_count = stats.vacuum_count + 1;
    }

    public fun initialize(admin: &signer) {
        move_to(admin, VacuumStats {
            total_vacuumed: 0,
            total_fees: 0,
            vacuum_count: 0
        });
    }
}
