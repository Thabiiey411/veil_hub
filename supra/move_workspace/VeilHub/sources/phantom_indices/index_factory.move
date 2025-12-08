module phantom_indices::index_factory {
    use std::signer;
    use std::vector;
    use veil_hub::veil_token;
    
    struct PhantomIndex has key {
        name: vector<u8>,
        assets: vector<address>,
        weights: vector<u64>,
        total_value: u128,
        creator: address,
    }
    
    const INDEX_CREATION_FEE: u64 = 10000_00000000;
    
    public entry fun create_index(
        account: &signer,
        name: vector<u8>,
        assets: vector<address>,
        weights: vector<u64>
    ) {
        veil_token::burn(account, INDEX_CREATION_FEE);
        
        move_to(account, PhantomIndex {
            name,
            assets,
            weights,
            total_value: 0,
            creator: signer::address_of(account),
        });
    }
}
