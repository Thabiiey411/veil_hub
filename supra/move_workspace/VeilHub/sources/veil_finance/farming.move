module veil_finance::farming {
    use std::signer;
    use supra_framework::coin;
    
    struct FarmPool has key {
        total_staked: u64,
        reward_per_second: u64,
        last_reward_time: u64,
        accumulated_reward: u128,
    }
    
    struct UserStake has key {
        amount: u64,
        reward_debt: u128,
        pending_reward: u64,
    }
    
    const REWARD_PER_SECOND: u64 = 1000000; // 0.01 VEIL per second
    
    public entry fun initialize(account: &signer) {
        move_to(account, FarmPool {
            total_staked: 0,
            reward_per_second: REWARD_PER_SECOND,
            last_reward_time: supra_framework::timestamp::now_seconds(),
            accumulated_reward: 0,
        });
    }
    
    public entry fun stake(account: &signer, amount: u64) acquires FarmPool {
        let pool = borrow_global_mut<FarmPool>(@veil_finance);
        pool.total_staked = pool.total_staked + amount;
        
        move_to(account, UserStake {
            amount,
            reward_debt: 0,
            pending_reward: 0,
        });
    }
    
    public entry fun claim_rewards(account: &signer) acquires UserStake, FarmPool {
        let stake = borrow_global_mut<UserStake>(signer::address_of(account));
        let reward = stake.pending_reward;
        stake.pending_reward = 0;
    }
}
