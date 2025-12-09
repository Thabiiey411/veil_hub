module veil_hub::veil_token {
    use std::signer;
    use std::string;
    use supra_framework::coin;
    use veil_hub::access_control;

    const E_ZERO_AMOUNT: u64 = 1;
    const E_EXCEEDS_SUPPLY: u64 = 2;
    const TOTAL_SUPPLY: u64 = 1000000000_00000000;
    const RESERVE_FLOOR: u64 = 100000000_00000000;

    struct VeilToken has key {}

    struct VeilCap has key {
        mint_cap: coin::MintCapability<VeilToken>,
        burn_cap: coin::BurnCapability<VeilToken>,
        freeze_cap: coin::FreezeCapability<VeilToken>,
        total_burned: u64,
    }

    public entry fun initialize(account: &signer) acquires access_control::AdminRole {
        access_control::assert_admin(account);
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<VeilToken>(
            account,
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
