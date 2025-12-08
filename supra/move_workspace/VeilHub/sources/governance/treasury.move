module governance::treasury {
    use std::signer;
    
    struct Treasury has key {
        total_revenue: u64,
        usdc_distributed: u64,
        veil_burned: u64,
    }
    
    public entry fun initialize(account: &signer) {
        move_to(account, Treasury {
            total_revenue: 0,
            usdc_distributed: 0,
            veil_burned: 0,
        });
    }
    
    public entry fun record_revenue(account: &signer, amount: u64) acquires Treasury {
        let treasury = borrow_global_mut<Treasury>(@governance);
        treasury.total_revenue = treasury.total_revenue + amount;
    }

    public fun deposit_vacuum_fee(amount: u64) acquires Treasury {
        let treasury = borrow_global_mut<Treasury>(@governance);
        treasury.total_revenue = treasury.total_revenue + amount;
    }

    public fun deposit_pol_fees(amount: u64) acquires Treasury {
        let treasury = borrow_global_mut<Treasury>(@governance);
        treasury.total_revenue = treasury.total_revenue + amount;
    }
}
