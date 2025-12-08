/// Debt Engine - Borrowing protocol at 5.5% APR
module veil_hub::debt_engine {
    use std::signer;

    struct Loan has key {
        borrowed: u64,
        accrued_interest: u64,
        last_update: u64,
        active: bool,
    }

    struct LendingPool has key {
        total_borrowed: u64,
        total_interest_collected: u64,
        interest_rate_bps: u64, // 550 = 5.5%
        active: bool,
    }

    const INTEREST_RATE_BPS: u64 = 550; // 5.5% APR
    const E_NO_LOAN: u64 = 1;
    const E_INSUFFICIENT_FUNDS: u64 = 2;
    const E_ZERO_AMOUNT: u64 = 3;

    /// Initialize the lending pool
    public entry fun initialize(admin: &signer) {
        move_to(admin, LendingPool {
            total_borrowed: 0,
            total_interest_collected: 0,
            interest_rate_bps: INTEREST_RATE_BPS,
            active: true,
        });
    }

    /// Borrow tokens from the pool
    public entry fun borrow(user: &signer, amount: u64) acquires LendingPool, Loan {
        assert!(amount > 0, E_ZERO_AMOUNT);

        let pool = borrow_global_mut<LendingPool>(@veil_hub);
        assert!(pool.active, 4);

        pool.total_borrowed = pool.total_borrowed + amount;

        let addr = signer::address_of(user);
        if (exists<Loan>(addr)) {
            let loan = borrow_global_mut<Loan>(addr);
            loan.borrowed = loan.borrowed + amount;
        } else {
            move_to(user, Loan {
                borrowed: amount,
                accrued_interest: 0,
                last_update: 0,
                active: true,
            });
        };
    }

    /// Repay borrowed tokens with interest
    public entry fun repay(user: &signer, amount: u64) acquires LendingPool, Loan {
        assert!(amount > 0, E_ZERO_AMOUNT);

        let addr = signer::address_of(user);
        assert!(exists<Loan>(addr), E_NO_LOAN);

        let loan = borrow_global_mut<Loan>(addr);
        let pool = borrow_global_mut<LendingPool>(@veil_hub);

        assert!(loan.borrowed >= amount, E_INSUFFICIENT_FUNDS);

        loan.borrowed = loan.borrowed - amount;
        pool.total_borrowed = pool.total_borrowed - amount;

        // Calculate interest: amount * (550 / 10000) = amount * 0.055
        let interest = (amount * INTEREST_RATE_BPS) / 10000;
        loan.accrued_interest = loan.accrued_interest + interest;
        pool.total_interest_collected = pool.total_interest_collected + interest;
    }

    /// Get loan details
    public fun get_loan(user: address): (u64, u64) acquires Loan {
        if (exists<Loan>(user)) {
            let loan = borrow_global<Loan>(user);
            (loan.borrowed, loan.accrued_interest)
        } else {
            (0, 0)
        }
    }

    /// Get pool stats
    public fun get_pool_stats(): (u64, u64) acquires LendingPool {
        let pool = borrow_global<LendingPool>(@veil_hub);
        (pool.total_borrowed, pool.total_interest_collected)
    }
}
