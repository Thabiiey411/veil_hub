/// Veil Token Module - Core token of the Veil ecosystem
/// Supply: 1B VEIL (8 decimals)
/// Reserve Floor: 100M (10% protection)
module veil_hub::veil_token {
    use std::signer;

    struct VeilToken {}

    struct TokenMetadata has key {
        total_supply: u64,
        total_burned: u64,
        reserve_floor: u64,
        decimals: u8,
    }

    struct Balance has key {
        amount: u64,
    }

    const TOTAL_SUPPLY: u64 = 1000000000_00000000;
    const RESERVE_FLOOR: u64 = 100000000_00000000;
    const DECIMALS: u8 = 8;

    const E_ZERO_AMOUNT: u64 = 1;
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    const E_EXCEEDS_SUPPLY: u64 = 3;
    const E_BELOW_RESERVE: u64 = 4;
    const E_ALREADY_INITIALIZED: u64 = 5;

    public entry fun initialize(account: &signer) {
        let addr = signer::address_of(account);
        assert!(!exists<TokenMetadata>(addr), E_ALREADY_INITIALIZED);

        move_to(account, TokenMetadata {
            total_supply: TOTAL_SUPPLY,
            total_burned: 0,
            reserve_floor: RESERVE_FLOOR,
            decimals: DECIMALS,
        });

        move_to(account, Balance { amount: TOTAL_SUPPLY });
    }

    public fun burn(account: &signer, amount: u64) acquires TokenMetadata, Balance {
        assert!(amount > 0, E_ZERO_AMOUNT);

        let addr = signer::address_of(account);
        let balance = borrow_global_mut<Balance>(addr);
        assert!(balance.amount >= amount, E_INSUFFICIENT_BALANCE);

        let metadata = borrow_global_mut<TokenMetadata>(addr);
        let new_supply = metadata.total_supply - amount;
        assert!(new_supply >= metadata.reserve_floor, E_BELOW_RESERVE);

        balance.amount = balance.amount - amount;
        metadata.total_supply = new_supply;
        metadata.total_burned = metadata.total_burned + amount;
    }

    public fun transfer(from: &signer, to: address, amount: u64) acquires Balance {
        assert!(amount > 0, E_ZERO_AMOUNT);

        let from_addr = signer::address_of(from);
        let from_balance = borrow_global_mut<Balance>(from_addr);
        assert!(from_balance.amount >= amount, E_INSUFFICIENT_BALANCE);

        from_balance.amount = from_balance.amount - amount;
        
        if (exists<Balance>(to)) {
            let to_balance = borrow_global_mut<Balance>(to);
            to_balance.amount = to_balance.amount + amount;
        };
    }

    public fun balance_of(account: address): u64 acquires Balance {
        if (exists<Balance>(account)) {
            borrow_global<Balance>(account).amount
        } else {
            0
        }
    }

    public fun total_supply(): u64 acquires TokenMetadata {
        borrow_global<TokenMetadata>(@veil_token).total_supply
    }

    public fun total_burned(): u64 acquires TokenMetadata {
        borrow_global<TokenMetadata>(@veil_token).total_burned
    }

    public fun decimals(): u8 acquires TokenMetadata {
        borrow_global<TokenMetadata>(@veil_token).decimals
    }
}
