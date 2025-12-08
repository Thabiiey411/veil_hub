module veil_hub::ai_governance {
    use std::signer;
    use std::vector;
    use veil_hub::access_control;
    use integrations::supra_oracle;

    const E_NOT_AUTHORIZED: u64 = 1;
    const E_INVALID_SCORE: u64 = 2;
    const E_PROPOSAL_EXISTS: u64 = 3;

    struct AIProposal has key, store {
        id: u64,
        strategy_type: u8,
        risk_score: u64,
        expected_apr: u64,
        ai_confidence: u64,
        executed: bool,
        timestamp: u64
    }

    struct GovernanceState has key {
        proposals: vector<AIProposal>,
        total_proposals: u64,
        auto_execute_threshold: u64,
        paused: bool
    }

    public fun initialize(admin: &signer) acquires access_control::AdminRole {
        access_control::assert_admin(admin);
        move_to(admin, GovernanceState {
            proposals: vector::empty(),
            total_proposals: 0,
            auto_execute_threshold: 80,
            paused: false
        });
    }

    public entry fun create_ai_proposal(
        admin: &signer,
        strategy_type: u8,
        expected_apr: u64
    ) acquires GovernanceState, access_control::AdminRole {
        access_control::assert_admin(admin);
        let state = borrow_global_mut<GovernanceState>(@veil_hub);
        assert!(!state.paused, E_NOT_AUTHORIZED);

        let risk_score = calculate_risk_score(strategy_type, expected_apr);
        let ai_confidence = get_ai_confidence(strategy_type);

        let proposal = AIProposal {
            id: state.total_proposals,
            strategy_type,
            risk_score,
            expected_apr,
            ai_confidence,
            executed: false,
            timestamp: supra_framework::timestamp::now_seconds()
        };

        vector::push_back(&mut state.proposals, proposal);
        state.total_proposals = state.total_proposals + 1;

        if (ai_confidence >= state.auto_execute_threshold) {
            execute_proposal(state.total_proposals - 1, state);
        };
    }

    fun calculate_risk_score(strategy_type: u8, expected_apr: u64): u64 {
        if (expected_apr > 100) { 80 }
        else if (expected_apr > 50) { 50 }
        else { 20 }
    }

    fun get_ai_confidence(strategy_type: u8): u64 {
        if (strategy_type == 1) { 85 }
        else if (strategy_type == 2) { 75 }
        else { 65 }
    }

    fun execute_proposal(proposal_id: u64, state: &mut GovernanceState) {
        let proposal = vector::borrow_mut(&mut state.proposals, proposal_id);
        proposal.executed = true;
    }

    public fun get_active_proposals(): u64 acquires GovernanceState {
        let state = borrow_global<GovernanceState>(@veil_hub);
        state.total_proposals
    }
}
