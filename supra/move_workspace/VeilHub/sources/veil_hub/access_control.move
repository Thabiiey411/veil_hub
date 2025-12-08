module veil_hub::access_control {
    use std::signer;
    use std::vector;

    const E_NOT_ADMIN: u64 = 1;
    const E_NOT_AUTHORIZED: u64 = 2;
    const E_ALREADY_ADMIN: u64 = 3;

    struct AdminRole has key {
        admins: vector<address>,
        paused: bool
    }

    public fun initialize(account: &signer) {
        let admin_addr = signer::address_of(account);
        move_to(account, AdminRole {
            admins: vector::singleton(admin_addr),
            paused: false
        });
    }

    public fun is_admin(addr: address): bool acquires AdminRole {
        if (!exists<AdminRole>(@veil_hub)) return false;
        let role = borrow_global<AdminRole>(@veil_hub);
        vector::contains(&role.admins, &addr)
    }

    public fun assert_admin(account: &signer) acquires AdminRole {
        assert!(is_admin(signer::address_of(account)), E_NOT_ADMIN);
    }

    public fun assert_not_paused() acquires AdminRole {
        let role = borrow_global<AdminRole>(@veil_hub);
        assert!(!role.paused, E_NOT_AUTHORIZED);
    }

    public entry fun pause(account: &signer) acquires AdminRole {
        assert_admin(account);
        let role = borrow_global_mut<AdminRole>(@veil_hub);
        role.paused = true;
    }

    public entry fun unpause(account: &signer) acquires AdminRole {
        assert_admin(account);
        let role = borrow_global_mut<AdminRole>(@veil_hub);
        role.paused = false;
    }
}
