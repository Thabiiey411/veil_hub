module governance::pol_manager {
    use supra_framework::coin::{Self, Coin};
    use supra_framework::signer;
    use veil_finance::router;
    use veil_finance::amm;
    use governance::treasury;

    const E_UNAUTHORIZED: u64 = 1;
    const E_INSUFFICIENT_BALANCE: u64 = 2;

    struct POLStats has key {
        total_liquidity: u64,
        lp_tokens_owned: u64,
        fees_earned: u64,
        last_acquisition: u64
    }

    struct LPTokenStore<phantom TokenA, phantom TokenB> has key {
        lp_tokens: u64
    }

    public entry fun acquire_liquidity<USDC, VEIL>(
        treasury_signer: &signer,
        usdc_amount: u64
    ) acquires POLStats, LPTokenStore {
        assert!(signer::address_of(treasury_signer) == @governance, E_UNAUTHORIZED);
        assert!(usdc_amount > 0, E_INSUFFICIENT_BALANCE);

        let veil_amount = router::swap<USDC, VEIL>(treasury_signer, usdc_amount / 2);
        
        let lp_tokens = amm::add_liquidity<USDC, VEIL>(
            treasury_signer,
            usdc_amount / 2,
            veil_amount
        );

        if (!exists<LPTokenStore<USDC, VEIL>>(@governance)) {
            move_to(treasury_signer, LPTokenStore<USDC, VEIL> { lp_tokens: 0 });
        };

        let store = borrow_global_mut<LPTokenStore<USDC, VEIL>>(@governance);
        store.lp_tokens = store.lp_tokens + lp_tokens;

        update_stats(usdc_amount, lp_tokens);
    }

    public entry fun claim_fees<TokenA, TokenB>(
        treasury_signer: &signer
    ) acquires POLStats {
        assert!(signer::address_of(treasury_signer) == @governance, E_UNAUTHORIZED);
        
        let fees = amm::claim_lp_fees<TokenA, TokenB>(@governance);
        treasury::deposit_pol_fees(fees);

        let stats = borrow_global_mut<POLStats>(@governance);
        stats.fees_earned = stats.fees_earned + fees;
    }

    fun update_stats(liquidity: u64, lp_tokens: u64) acquires POLStats {
        let stats = borrow_global_mut<POLStats>(@governance);
        stats.total_liquidity = stats.total_liquidity + liquidity;
        stats.lp_tokens_owned = stats.lp_tokens_owned + lp_tokens;
        stats.last_acquisition = supra_framework::timestamp::now_seconds();
    }

    public fun get_pol_value<TokenA, TokenB>(): u64 acquires LPTokenStore {
        if (!exists<LPTokenStore<TokenA, TokenB>>(@governance)) return 0;
        let store = borrow_global<LPTokenStore<TokenA, TokenB>>(@governance);
        amm::get_lp_value<TokenA, TokenB>(store.lp_tokens)
    }

    public fun initialize(admin: &signer) {
        move_to(admin, POLStats {
            total_liquidity: 0,
            lp_tokens_owned: 0,
            fees_earned: 0,
            last_acquisition: 0
        });
    }
}
