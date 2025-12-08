module phantom_indices::rebalancer {
    use std::signer;
    use phantom_indices::index_factory;
    
    struct RebalanceConfig has key {
        threshold_bps: u64,
        last_rebalance: u64,
        min_interval: u64,
    }
    
    const REBALANCE_THRESHOLD: u64 = 1000; // 10%
    const MIN_INTERVAL: u64 = 86400; // 24 hours
    
    public entry fun initialize(account: &signer) {
        move_to(account, RebalanceConfig {
            threshold_bps: REBALANCE_THRESHOLD,
            last_rebalance: 0,
            min_interval: MIN_INTERVAL,
        });
    }
    
    public entry fun rebalance_index(account: &signer) acquires RebalanceConfig {
        let config = borrow_global_mut<RebalanceConfig>(@phantom_indices);
        config.last_rebalance = supra_framework::timestamp::now_seconds();
    }
}
