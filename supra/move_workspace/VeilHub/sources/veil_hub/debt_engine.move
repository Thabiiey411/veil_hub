module veil_hub::debt_engine {
    use std::signer;
    use veil_hub::access_control;

    const E_ZERO_AMOUNT: u64 = 1;
    const E_INSUFFICIENT_COLLATERAL: u64 = 2;
    const E_REPAY_EXCEEDS_DEBT: u64 = 3;
    const E_NO_DEBT: u64 = 4;
    const E_OVERFLOW: u64 = 5;

    struct Debt has key {
        collateral: u64,
        borrowed: u64,
        interest_rate: u64,
        last_update: u64,
    }

    struct DebtConfig has key {
        min_collateral_ratio: u64,
        liquidation_ratio: u64,
        interest_rate: u64,
    }

    public entry fun initialize(account: &signer) acquires access_control::AdminRole {
        access_control::assert_admin(account);
        move_to(account, DebtConfig {
            min_collateral_ratio: 180,
            liquidation_ratio: 120,
            interest_rate: 550,
        });
    }

    public entry fun borrow(account: &signer, collateral: u64, amount: u64) acquires DebtConfig, access_control::AdminRole {
        access_control::assert_not_paused();
        assert!(collateral > 0 && amount > 0, E_ZERO_AMOUNT);
        assert!(!exists<Debt>(signer::address_of(account)), E_NO_DEBT);
        
        let config = borrow_global<DebtConfig>(@veil_hub);
        let ratio = (collateral * 100) / amount;
        assert!(ratio >= config.min_collateral_ratio, E_INSUFFICIENT_COLLATERAL);

        move_to(account, Debt {
            collateral,
            borrowed: amount,
            interest_rate: config.interest_rate,
            last_update: supra_framework::timestamp::now_seconds(),
        });
    }

    public entry fun repay(account: &signer, amount: u64) acquires Debt, access_control::AdminRole {
        access_control::assert_not_paused();
        assert!(amount > 0, E_ZERO_AMOUNT);
        assert!(exists<Debt>(signer::address_of(account)), E_NO_DEBT);
        
        let debt = borrow_global_mut<Debt>(signer::address_of(account));
        assert!(amount <= debt.borrowed, E_REPAY_EXCEEDS_DEBT);
        debt.borrowed = debt.borrowed - amount;
    }
}
