/// Farming - Yield generation through LP staking
/// Rewards: 0.01 VEIL per second per farm
module veil_finance::farming {
    use std::signer;

    struct Farm<phantom T> has key {
        total_staked: u64,
        reward_per_second: u64,
        last_update: u64,
        accumulated_reward: u128,
        active: bool,
    }

    struct Stake<phantom T> has key {
        amount: u64,
        reward_debt: u128,
        timestamp: u64,
    }

    const REWARD_PER_SECOND: u64 = 10000000; // 0.1 VEIL per second
    const E_INVALID_AMOUNT: u64 = 1;
    const E_NO_STAKE: u64 = 2;
    const E_FARM_EXISTS: u64 = 3;

    /// Initialize a farm
    public entry fun initialize_farm<T>(admin: &signer) {
        move_to(admin, Farm<T> {
            total_staked: 0,
            reward_per_second: REWARD_PER_SECOND,
            last_update: 0,
            accumulated_reward: 0,
            active: true,
        });
    }

    /// Stake tokens in farm
    public entry fun stake<T>(user: &signer, amount: u64) acquires Farm, Stake {
        assert!(amount > 0, E_INVALID_AMOUNT);

        let addr = signer::address_of(user);
        let farm = borrow_global_mut<Farm<T>>(@veil_finance);
        assert!(farm.active, 3);

        farm.total_staked = farm.total_staked + amount;

        if (exists<Stake<T>>(addr)) {
            let stake = borrow_global_mut<Stake<T>>(addr);
            stake.amount = stake.amount + amount;
        } else {
            move_to(user, Stake<T> {
                amount,
                reward_debt: 0,
                timestamp: 0,
            });
        };
    }

    /// Unstake tokens from farm
    public entry fun unstake<T>(user: &signer, amount: u64) acquires Farm, Stake {
        assert!(amount > 0, E_INVALID_AMOUNT);

        let addr = signer::address_of(user);
        assert!(exists<Stake<T>>(addr), E_NO_STAKE);

        let stake = borrow_global_mut<Stake<T>>(addr);
        assert!(stake.amount >= amount, 4);

        let farm = borrow_global_mut<Farm<T>>(@veil_finance);
        farm.total_staked = farm.total_staked - amount;
        stake.amount = stake.amount - amount;
    }

    /// Claim farming rewards
    public entry fun claim_rewards<T>(user: &signer) acquires Farm, Stake {
        let addr = signer::address_of(user);
        assert!(exists<Stake<T>>(addr), E_NO_STAKE);

        let stake = borrow_global_mut<Stake<T>>(addr);
        let farm = borrow_global_mut<Farm<T>>(@veil_finance);

        // Calculate pending rewards
        let pending = calculate_rewards(farm, stake);
        stake.reward_debt = farm.accumulated_reward;

        // In real implementation, transfer pending VEIL tokens
        // For now, just update the state
    }

    fun calculate_rewards<T>(farm: &Farm<T>, stake: &Stake<T>): u64 {
        let rewards = (farm.accumulated_reward - stake.reward_debt);
        ((rewards as u64) * stake.amount) / (farm.total_staked + 1)
    }

    /// Get user stake
    public fun get_stake<T>(user: address): u64 acquires Stake {
        if (exists<Stake<T>>(user)) {
            borrow_global<Stake<T>>(user).amount
        } else {
            0
        }
    }

    /// Get total staked in farm
    public fun get_total_staked<T>(): u64 acquires Farm {
        borrow_global<Farm<T>>(@veil_finance).total_staked
    }
}
