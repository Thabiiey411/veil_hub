module veil_hub::supra_vrf {
    use std::signer;
    
    struct VRFRequest has key {
        request_id: u64,
        random_value: u64,
        fulfilled: bool,
    }
    
    public entry fun request_randomness(account: &signer) {
        move_to(account, VRFRequest {
            request_id: 0,
            random_value: 0,
            fulfilled: false,
        });
    }
    
    public entry fun fulfill_randomness(account: &signer, random: u64) acquires VRFRequest {
        let request = borrow_global_mut<VRFRequest>(signer::address_of(account));
        request.random_value = random;
        request.fulfilled = true;
    }
    
    public fun get_random(): u64 acquires VRFRequest {
        borrow_global<VRFRequest>(@veil_hub).random_value
    }
}
