module phantom_indices::stable_bundle {
    use std::signer;
    use veil_hub::veil_token;
    
    struct StableBundle has key {
        usdc_amount: u64,
        usdt_amount: u64,
        dai_amount: u64,
        total_shares: u64,
        total_yield: u64,
    }
    
    const BUNDLE_CREATION_FEE: u64 = 5000_00000000;
    const ENTRY_FEE_BPS: u64 = 30;
    
    public entry fun create_bundle(account: &signer) {
        veil_token::burn(account, BUNDLE_CREATION_FEE);
        
        move_to(account, StableBundle {
            usdc_amount: 0,
            usdt_amount: 0,
            dai_amount: 0,
            total_shares: 0,
            total_yield: 0,
        });
    }
}
