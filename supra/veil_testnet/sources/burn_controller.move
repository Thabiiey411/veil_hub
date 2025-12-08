/// Burn Controller - Phase-based token burning with supply floor protection
/// Phase 1: 30% burn cap
/// Phase 2: 20% burn cap
/// Phase 3: 10% burn cap
/// Reserve Floor: 100M VEIL (never burned)
module veil_hub::burn_controller {
    use std::signer;

    struct BurnPhase has key {
        phase: u8, // 1, 2, or 3
        total_burned: u64,
        burn_cap: u64, // Max amount that can be burned in this phase
        burned_in_phase: u64,
        active: bool,
    }

    const RESERVE_FLOOR: u64 = 100000000_00000000; // 100M VEIL
    const TOTAL_SUPPLY: u64 = 1000000000_00000000; // 1B VEIL

    // Phase burn caps
    const PHASE_1_CAP: u64 = 300000000_00000000; // 30% = 300M
    const PHASE_2_CAP: u64 = 200000000_00000000; // 20% = 200M
    const PHASE_3_CAP: u64 = 100000000_00000000; // 10% = 100M

    const E_PHASE_CAP_EXCEEDED: u64 = 1;
    const E_ZERO_AMOUNT: u64 = 2;
    const E_BELOW_RESERVE: u64 = 3;
    const E_INVALID_PHASE: u64 = 4;

    /// Initialize burn phases
    public entry fun initialize(admin: &signer) {
        move_to(admin, BurnPhase {
            phase: 1,
            total_burned: 0,
            burn_cap: PHASE_1_CAP,
            burned_in_phase: 0,
            active: true,
        });
    }

    /// Execute burn operation with phase protection
    public entry fun execute_burn(admin: &signer, amount: u64) acquires BurnPhase {
        assert!(amount > 0, E_ZERO_AMOUNT);

        let controller = borrow_global_mut<BurnPhase>(signer::address_of(admin));
        assert!(controller.active, 5);

        // Check if burn would exceed phase cap
        assert!(controller.burned_in_phase + amount <= controller.burn_cap, E_PHASE_CAP_EXCEEDED);

        // Check if burn would violate reserve floor
        let remaining_supply = TOTAL_SUPPLY - controller.total_burned - amount;
        assert!(remaining_supply >= RESERVE_FLOOR, E_BELOW_RESERVE);

        controller.total_burned = controller.total_burned + amount;
        controller.burned_in_phase = controller.burned_in_phase + amount;
    }

    /// Advance to next burn phase
    public entry fun advance_phase(admin: &signer) acquires BurnPhase {
        let controller = borrow_global_mut<BurnPhase>(signer::address_of(admin));
        assert!(controller.phase < 3, 6);

        controller.phase = controller.phase + 1;
        controller.burned_in_phase = 0;

        controller.burn_cap = if (controller.phase == 2) {
            PHASE_2_CAP
        } else if (controller.phase == 3) {
            PHASE_3_CAP
        } else {
            PHASE_1_CAP
        };
    }

    /// Get current phase info
    public fun get_phase_info(): (u8, u64, u64, u64) acquires BurnPhase {
        let controller = borrow_global<BurnPhase>(@veil_hub);
        (controller.phase, controller.burn_cap, controller.burned_in_phase, controller.total_burned)
    }

    /// Get remaining burn capacity in current phase
    public fun get_remaining_capacity(): u64 acquires BurnPhase {
        let controller = borrow_global<BurnPhase>(@veil_hub);
        controller.burn_cap - controller.burned_in_phase
    }

    /// Check if amount would breach reserve floor
    public fun can_burn(amount: u64): bool acquires BurnPhase {
        let controller = borrow_global<BurnPhase>(@veil_hub);
        let remaining = TOTAL_SUPPLY - controller.total_burned - amount;
        remaining >= RESERVE_FLOOR && controller.burned_in_phase + amount <= controller.burn_cap
    }
}
