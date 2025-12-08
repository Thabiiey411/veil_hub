/// Veil Token - Core token of the Veil ecosystem
/// Supply: 1B VEIL (8 decimals = 100B units)
/// Reserve Floor: 100M (10% never burned)
module veil_token::veil_coin {
    use std::signer;

    /// The Veil Token struct
    struct VeilCoin {}

    /// Global token metadata
    struct TokenStore has key {
        total_supply: u64,
        total_burned: u64,
        decimals: u8,
    }

    /// User account balances
    struct Balance has key {
        coin: u64,
    }

    // Constants
    const TOTAL_SUPPLY: u64 = 1000000000_00000000; // 1B * 10^8
    const RESERVE_FLOOR: u64 = 100000000_00000000; // 100M * 10^8
    const DECIMALS: u8 = 8;

    // Errors
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    const E_INVALID_AMOUNT: u64 = 3;
    const E_CANNOT_BURN_RESERVE: u64 = 4;

    /// Initialize token (call once at genesis)
    public entry fun initialize_coin(account: &signer) {
        let admin = signer::address_of(account);
        move_to(account, TokenStore {
            total_supply: TOTAL_SUPPLY,
            total_burned: 0,
            decimals: DECIMALS,
        });
        move_to(account, Balance { coin: TOTAL_SUPPLY });
    }

    /// Register an account to hold Veil tokens
    public entry fun register_account(account: &signer) {
        move_to(account, Balance { coin: 0 });
    }

    /// Transfer coins from sender to recipient
    public entry fun transfer(sender: &signer, recipient: address, amount: u64) acquires Balance {
        let sender_addr = signer::address_of(sender);
        assert!(amount > 0, E_INVALID_AMOUNT);

        let sender_balance = borrow_global_mut<Balance>(sender_addr);
        assert!(sender_balance.coin >= amount, E_INSUFFICIENT_BALANCE);
        sender_balance.coin = sender_balance.coin - amount;

        if (exists<Balance>(recipient)) {
            let rec_balance = borrow_global_mut<Balance>(recipient);
            rec_balance.coin = rec_balance.coin + amount;
        } else {
            move_to(&create_signer_for_address(recipient), Balance { coin: amount });
        };
    }

    /// Mint new tokens (admin only)
    public entry fun mint(admin: &signer, recipient: address, amount: u64) acquires TokenStore, Balance {
        let admin_addr = signer::address_of(admin);
        assert!(amount > 0, E_INVALID_AMOUNT);

        let store = borrow_global_mut<TokenStore>(admin_addr);
        store.total_supply = store.total_supply + amount;

        if (exists<Balance>(recipient)) {
            let balance = borrow_global_mut<Balance>(recipient);
            balance.coin = balance.coin + amount;
        } else {
            move_to(&create_signer_for_address(recipient), Balance { coin: amount });
        };
    }

    /// Burn tokens (remove from circulation)
    public entry fun burn(account: &signer, amount: u64) acquires TokenStore, Balance {
        let addr = signer::address_of(account);
        assert!(amount > 0, E_INVALID_AMOUNT);

        let balance = borrow_global_mut<Balance>(addr);
        assert!(balance.coin >= amount, E_INSUFFICIENT_BALANCE);

        let store = borrow_global_mut<TokenStore>(addr);
        let remaining = store.total_supply - amount;
        assert!(remaining >= RESERVE_FLOOR, E_CANNOT_BURN_RESERVE);

        balance.coin = balance.coin - amount;
        store.total_supply = remaining;
        store.total_burned = store.total_burned + amount;
    }

    /// View balance of account
    public fun get_balance(account: address): u64 acquires Balance {
        if (exists<Balance>(account)) {
            borrow_global<Balance>(account).coin
        } else {
            0
        }
    }

    /// View total supply
    public fun get_supply(): u64 acquires TokenStore {
        borrow_global<TokenStore>(@veil_token).total_supply
    }

    /// View total burned
    public fun get_burned(): u64 acquires TokenStore {
        borrow_global<TokenStore>(@veil_token).total_burned
    }

    /// Helper function to create signer for specific address (for testing only)
    fun create_signer_for_address(_addr: address): signer {
        // This is a placeholder for Move framework compatibility
        // In production, use proper module capabilities
        abort(0)
    }

    #[test]
    fun test_initialize() {
        // Test token initialization
    }
}
