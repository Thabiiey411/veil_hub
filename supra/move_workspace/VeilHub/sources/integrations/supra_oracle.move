module veil_hub::supra_oracle {
    use std::signer;
    use supra_framework::timestamp;
    
    struct PriceCache has key {
        btc_price: u128,
        eth_price: u128,
        link_price: u128,
        avax_price: u128,
        last_update: u64,
    }
    
    public entry fun initialize(account: &signer) {
        move_to(account, PriceCache {
            btc_price: 0,
            eth_price: 0,
            link_price: 0,
            avax_price: 0,
            last_update: 0,
        });
    }
    
    public fun get_btc_price(): u128 acquires PriceCache {
        borrow_global<PriceCache>(@veil_hub).btc_price
    }
    
    public entry fun update_prices(
        _account: &signer,
        btc: u128,
        eth: u128,
        link: u128,
        avax: u128
    ) acquires PriceCache {
        let cache = borrow_global_mut<PriceCache>(@veil_hub);
        cache.btc_price = btc;
        cache.eth_price = eth;
        cache.link_price = link;
        cache.avax_price = avax;
        cache.last_update = timestamp::now_seconds();
    }
}
