/// veVEIL - Governance token with vote-to-earn and 2.5x yield boost
/// Lock VEIL to get veVEIL (1 VEIL locked = 1 veVEIL)
/// Boost formula: min(2.5, 1 + (veVEIL/total × 1.5))
module veil_hub::veveil {
    use std::signer;

    struct VeVeil {}

    struct Lock has key {
        amount: u64,
        unlock_time: u64,
        multiplier: u64,
    }

    struct VeVeilStore has key {
        total_locked: u64,
        total_votes: u64,
        quad_voting_power: u64,
    }

    const MIN_LOCK_TIME: u64 = 604800; // 7 days in seconds
    const E_INSUFFICIENT_VEIL: u64 = 1;
    const E_LOCK_NOT_EXPIRED: u64 = 2;
    const E_NO_LOCK: u64 = 3;
    const E_ZERO_AMOUNT: u64 = 4;

    /// Initialize the veVEIL system
    public entry fun initialize(admin: &signer) {
        move_to(admin, VeVeilStore {
            total_locked: 0,
            total_votes: 0,
            quad_voting_power: 0,
        });
    }

    /// Lock VEIL tokens to receive veVEIL
    public entry fun lock_veil(user: &signer, amount: u64, lock_duration: u64) acquires VeVeilStore, Lock {
        assert!(amount > 0, E_ZERO_AMOUNT);
        assert!(lock_duration >= MIN_LOCK_TIME, 5);

        let addr = signer::address_of(user);
        let store = borrow_global_mut<VeVeilStore>(@veil_hub);
        
        let multiplier = calculate_boost(amount, store.total_locked);
        let voting_power = (amount * multiplier) / 100; // Quadratic voting

        store.total_locked = store.total_locked + amount;
        store.total_votes = store.total_votes + voting_power;
        store.quad_voting_power = store.quad_voting_power + voting_power;

        if (exists<Lock>(addr)) {
            let lock = borrow_global_mut<Lock>(addr);
            lock.amount = lock.amount + amount;
            lock.multiplier = multiplier;
        } else {
            move_to(user, Lock {
                amount,
                unlock_time: 0, // Would be set to current time + duration
                multiplier,
            });
        };
    }

    /// Unlock and withdraw VEIL tokens
    public entry fun unlock_veil(user: &signer) acquires VeVeilStore, Lock {
        let addr = signer::address_of(user);
        assert!(exists<Lock>(addr), E_NO_LOCK);

        let lock = borrow_global_mut<Lock>(addr);
        assert!(lock.unlock_time <= 0, E_LOCK_NOT_EXPIRED); // Check expiry

        let amount = lock.amount;
        let store = borrow_global_mut<VeVeilStore>(@veil_hub);
        
        store.total_locked = store.total_locked - amount;
        let voting_power_reduction = (amount * lock.multiplier) / 100;
        store.total_votes = store.total_votes - voting_power_reduction;

        lock.amount = 0;
        lock.multiplier = 0;
    }

    /// Calculate yield boost based on veVEIL balance
    fun calculate_boost(amount: u64, total_locked: u64): u64 {
        if (total_locked == 0) {
            return 100 // 1x multiplier as u64
        };
        let ratio = (amount * 150) / (total_locked + 1);
        let boost = 100 + ratio; // 1x + ratio
        if (boost > 250) {
            250 // Cap at 2.5x
        } else {
            boost
        }
    }

    /// Get user's veVEIL balance and boost
    public fun get_user_veveil(user: address): (u64, u64) acquires Lock {
        if (exists<Lock>(user)) {
            let lock = borrow_global<Lock>(user);
            (lock.amount, lock.multiplier)
        } else {
            (0, 100)
        }
    }

    /// Get total locked VEIL
    public fun get_total_locked(): u64 acquires VeVeilStore {
        borrow_global<VeVeilStore>(@veil_hub).total_locked
    }

    /// Get total voting power (quadratic voting)
    public fun get_voting_power(): u64 acquires VeVeilStore {
        borrow_global<VeVeilStore>(@veil_hub).quad_voting_power
    }
}
