module veil_finance::yield_optimizer {
    use std::signer;
    use veil_hub::access_control;
    use veil_finance::amm;
    use veil_finance::farming;

    const E_ZERO_AMOUNT: u64 = 1;
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    const PERFORMANCE_FEE_BPS: u64 = 1000;

    struct YieldVault<phantom T> has key {
        total_deposited: u64,
        total_shares: u64,
        last_harvest: u64,
        accumulated_yield: u64,
        strategy_id: u8
    }

    struct UserPosition<phantom T> has key {
        shares: u64,
        deposited_amount: u64,
        entry_timestamp: u64
    }

    public entry fun deposit<T>(account: &signer, amount: u64) acquires YieldVault, UserPosition, access_control::AdminRole {
        access_control::assert_not_paused();
        assert!(amount > 0, E_ZERO_AMOUNT);

        if (!exists<YieldVault<T>>(@veil_finance)) {
            move_to(account, YieldVault<T> {
                total_deposited: 0,
                total_shares: 0,
                last_harvest: supra_framework::timestamp::now_seconds(),
                accumulated_yield: 0,
                strategy_id: 1
            });
        };

        let vault = borrow_global_mut<YieldVault<T>>(@veil_finance);
        let shares = if (vault.total_shares == 0) {
            amount
        } else {
            (amount * vault.total_shares) / vault.total_deposited
        };

        vault.total_deposited = vault.total_deposited + amount;
        vault.total_shares = vault.total_shares + shares;

        if (!exists<UserPosition<T>>(signer::address_of(account))) {
            move_to(account, UserPosition<T> {
                shares: 0,
                deposited_amount: 0,
                entry_timestamp: supra_framework::timestamp::now_seconds()
            });
        };

        let position = borrow_global_mut<UserPosition<T>>(signer::address_of(account));
        position.shares = position.shares + shares;
        position.deposited_amount = position.deposited_amount + amount;
    }

    public entry fun auto_compound<T>(admin: &signer) acquires YieldVault, access_control::AdminRole {
        access_control::assert_admin(admin);
        let vault = borrow_global_mut<YieldVault<T>>(@veil_finance);
        
        let yield_earned = calculate_yield(vault.total_deposited, vault.last_harvest);
        let fee = (yield_earned * PERFORMANCE_FEE_BPS) / 10000;
        let net_yield = yield_earned - fee;

        vault.accumulated_yield = vault.accumulated_yield + net_yield;
        vault.total_deposited = vault.total_deposited + net_yield;
        vault.last_harvest = supra_framework::timestamp::now_seconds();
    }

    fun calculate_yield(deposited: u64, last_harvest: u64): u64 {
        let time_elapsed = supra_framework::timestamp::now_seconds() - last_harvest;
        (deposited * time_elapsed * 15) / (365 * 24 * 3600 * 100)
    }

    public fun get_user_balance<T>(user: address): u64 acquires UserPosition, YieldVault {
        if (!exists<UserPosition<T>>(user)) return 0;
        let position = borrow_global<UserPosition<T>>(user);
        let vault = borrow_global<YieldVault<T>>(@veil_finance);
        (position.shares * vault.total_deposited) / vault.total_shares
    }
}
