module veil_hub::veveil_enhanced {
    use supra_framework::signer;
    use veil_hub::veveil;

    const MAX_BOOST: u64 = 250; // 2.5x
    const FEE_DISCOUNT_BPS: u64 = 5000; // 50%
    const E_NO_VEVEIL: u64 = 1;

    struct BoostConfig has key {
        enabled: bool,
        max_boost: u64,
        fee_discount: u64
    }

    public fun calculate_boost(user: address): u64 acquires BoostConfig {
        let config = borrow_global<BoostConfig>(@veil_hub);
        if (!config.enabled) return 100;

        let user_veveil = veveil::balance_of(user);
        if (user_veveil == 0) return 100;

        let total_veveil = veveil::total_supply();
        let boost = 100 + (user_veveil * 150 / total_veveil);
        
        if (boost > config.max_boost) config.max_boost else boost
    }

    public fun apply_fee_discount(user: address, fee: u64): u64 acquires BoostConfig {
        let config = borrow_global<BoostConfig>(@veil_hub);
        if (!config.enabled) return fee;

        if (veveil::balance_of(user) > 0) {
            fee * (10000 - config.fee_discount) / 10000
        } else {
            fee
        }
    }

    public fun get_voting_power(user: address): u64 {
        let veveil_balance = veveil::balance_of(user);
        sqrt(veveil_balance)
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

    public entry fun enable_boost(admin: &signer) acquires BoostConfig {
        let config = borrow_global_mut<BoostConfig>(@veil_hub);
        config.enabled = true;
    }

    public fun initialize(admin: &signer) {
        move_to(admin, BoostConfig {
            enabled: true,
            max_boost: MAX_BOOST,
            fee_discount: FEE_DISCOUNT_BPS
        });
    }
}
