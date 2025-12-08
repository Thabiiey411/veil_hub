/// Veil Token Module - Core token of the Veil ecosystem
/// Supply: 1B VEIL (8 decimals = 100B units)
/// Reserve Floor: 100M (10% protection)
module veil_hub::veil_token {
    use std::signer;

    /// Veil Token type
    struct VeilToken {}

    /// Token metadata and supply tracking
    struct TokenMetadata has key {
        total_supply: u64,
        total_burned: u64,
        reserve_floor: u64,
        decimals: u8,
    }

    /// User balance store
    struct Balance has key {
        amount: u64,
    }

    // ===== Constants =====
    const TOTAL_SUPPLY: u64 = 1000000000_00000000; // 1B with 8 decimals
    const RESERVE_FLOOR: u64 = 100000000_00000000; // 100M
    const DECIMALS: u8 = 8;

    // ===== Errors =====
    const E_ZERO_AMOUNT: u64 = 1;
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    const E_EXCEEDS_SUPPLY: u64 = 3;
    const E_BELOW_RESERVE: u64 = 4;
    const E_ALREADY_INITIALIZED: u64 = 5;

    /// Initialize the token module (call once from genesis)
    public entry fun initialize(account: &signer) {
        let addr = signer::address_of(account);
        assert!(!exists<TokenMetadata>(addr), E_ALREADY_INITIALIZED);

        move_to(account, TokenMetadata {
            total_supply: TOTAL_SUPPLY,
            total_burned: 0,
            reserve_floor: RESERVE_FLOOR,
            decimals: DECIMALS,
        });

        // Initialize admin account with full supply
        move_to(account, Balance { amount: TOTAL_SUPPLY });
            string::utf8(b"Veil Token"),
            string::utf8(b"VEIL"),
            8,
            true,
        );

        let coins = coin::mint<VeilToken>(TOTAL_SUPPLY, &mint_cap);
        coin::deposit(signer::address_of(account), coins);
        
        move_to(account, VeilCap { mint_cap, burn_cap, freeze_cap, total_burned: 0 });
    }

    public entry fun burn(account: &signer, amount: u64) acquires VeilCap, access_control::AdminRole {
        access_control::assert_not_paused();
        assert!(amount > 0, E_ZERO_AMOUNT);
        
        let caps = borrow_global_mut<VeilCap>(@veil_hub);
        assert!(caps.total_burned + amount <= TOTAL_SUPPLY - RESERVE_FLOOR, E_EXCEEDS_SUPPLY);
        
        let coins = coin::withdraw<VeilToken>(account, amount);
        coin::burn(coins, &caps.burn_cap);
        caps.total_burned = caps.total_burned + amount;
    }
}
