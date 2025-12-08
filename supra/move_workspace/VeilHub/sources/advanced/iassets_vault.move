module veil_finance::iassets_vault {
    use std::signer;
    use veil_hub::access_control;
    use integrations::supra_oracle;

    const E_ZERO_AMOUNT: u64 = 1;
    const E_INSUFFICIENT_COLLATERAL: u64 = 2;
    const E_VAULT_NOT_FOUND: u64 = 3;
    const COLLATERAL_RATIO: u64 = 150;

    struct IAsset<phantom T> has key, store {
        collateral_amount: u64,
        minted_iasset: u64,
        yield_earned: u64,
        last_update: u64,
        locked: bool
    }

    struct IAssetConfig has key {
        total_collateral: u64,
        total_minted: u64,
        base_yield_rate: u64,
        flywheel_multiplier: u64
    }

    public fun initialize(admin: &signer) acquires access_control::AdminRole {
        access_control::assert_admin(admin);
        move_to(admin, IAssetConfig {
            total_collateral: 0,
            total_minted: 0,
            base_yield_rate: 800,
            flywheel_multiplier: 120
        });
    }

    public entry fun deposit_and_mint<T>(
        account: &signer,
        collateral_amount: u64
    ) acquires IAssetConfig, IAsset, access_control::AdminRole {
        access_control::assert_not_paused();
        assert!(collateral_amount > 0, E_ZERO_AMOUNT);

        let config = borrow_global_mut<IAssetConfig>(@veil_finance);
        let price = get_asset_price<T>();
        let max_mint = (collateral_amount * price * 100) / COLLATERAL_RATIO;

        if (!exists<IAsset<T>>(signer::address_of(account))) {
            move_to(account, IAsset<T> {
                collateral_amount: 0,
                minted_iasset: 0,
                yield_earned: 0,
                last_update: supra_framework::timestamp::now_seconds(),
                locked: false
            });
        };

        let iasset = borrow_global_mut<IAsset<T>>(signer::address_of(account));
        assert!(!iasset.locked, E_VAULT_NOT_FOUND);

        iasset.collateral_amount = iasset.collateral_amount + collateral_amount;
        iasset.minted_iasset = iasset.minted_iasset + max_mint;

        config.total_collateral = config.total_collateral + collateral_amount;
        config.total_minted = config.total_minted + max_mint;
    }

    public entry fun claim_yield<T>(account: &signer) acquires IAsset, IAssetConfig, access_control::AdminRole {
        access_control::assert_not_paused();
        assert!(exists<IAsset<T>>(signer::address_of(account)), E_VAULT_NOT_FOUND);

        let iasset = borrow_global_mut<IAsset<T>>(signer::address_of(account));
        let config = borrow_global<IAssetConfig>(@veil_finance);

        let time_elapsed = supra_framework::timestamp::now_seconds() - iasset.last_update;
        let base_yield = (iasset.minted_iasset * config.base_yield_rate * time_elapsed) / (365 * 24 * 3600 * 10000);
        let flywheel_boost = (base_yield * config.flywheel_multiplier) / 100;
        let total_yield = base_yield + flywheel_boost;

        iasset.yield_earned = iasset.yield_earned + total_yield;
        iasset.last_update = supra_framework::timestamp::now_seconds();
    }

    fun get_asset_price<T>(): u64 {
        100
    }

    public fun get_vault_info<T>(user: address): (u64, u64, u64) acquires IAsset {
        if (!exists<IAsset<T>>(user)) return (0, 0, 0);
        let iasset = borrow_global<IAsset<T>>(user);
        (iasset.collateral_amount, iasset.minted_iasset, iasset.yield_earned)
    }

    public fun calculate_flywheel_apr<T>(user: address): u64 acquires IAsset, IAssetConfig {
        if (!exists<IAsset<T>>(user)) return 0;
        let config = borrow_global<IAssetConfig>(@veil_finance);
        (config.base_yield_rate * config.flywheel_multiplier) / 100
    }
}
