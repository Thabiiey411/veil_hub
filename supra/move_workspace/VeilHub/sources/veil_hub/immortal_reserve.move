module veil_hub::immortal_reserve {
    use std::signer;
    use supra_framework::coin;
    use veil_hub::access_control;

    const E_ZERO_AMOUNT: u64 = 1;
    const E_OVERFLOW: u64 = 2;
    const E_RESERVE_FLOOR: u64 = 3;
    const RESERVE_FLOOR: u64 = 100000000_00000000; // 100M VEIL
    const MAX_U64: u64 = 18446744073709551615;

    struct ImmortalShare has key {
        shares: u64,
        total_burned: u64,
    }

    struct Reserve has key {
        total_shares: u64,
        total_burned: u64,
        usdc_balance: u64,
    }

    public entry fun initialize(account: &signer) acquires access_control::AdminRole {
        access_control::assert_admin(account);
        move_to(account, Reserve {
            total_shares: 0,
            total_burned: 0,
            usdc_balance: 0,
        });
    }

    public entry fun burn_for_shares(account: &signer, amount: u64) acquires Reserve, ImmortalShare, access_control::AdminRole {
        access_control::assert_not_paused();
        assert!(amount > 0, E_ZERO_AMOUNT);
        
        let reserve = borrow_global_mut<Reserve>(@veil_hub);
        assert!(reserve.total_burned + amount <= MAX_U64 - RESERVE_FLOOR, E_OVERFLOW);
        
        let bonus = if (reserve.total_burned < 100000000_00000000) {
            15
        } else if (reserve.total_burned < 300000000_00000000) {
            12
        } else {
            10
        };

        let shares = (amount * bonus) / 10;
        assert!(reserve.total_shares + shares <= MAX_U64, E_OVERFLOW);
        
        reserve.total_shares = reserve.total_shares + shares;
        reserve.total_burned = reserve.total_burned + amount;

        if (!exists<ImmortalShare>(signer::address_of(account))) {
            move_to(account, ImmortalShare { shares: 0, total_burned: 0 });
        };

        let user_share = borrow_global_mut<ImmortalShare>(signer::address_of(account));
        assert!(user_share.shares + shares <= MAX_U64, E_OVERFLOW);
        assert!(user_share.total_burned + amount <= MAX_U64, E_OVERFLOW);
        
        user_share.shares = user_share.shares + shares;
        user_share.total_burned = user_share.total_burned + amount;
    }
}
