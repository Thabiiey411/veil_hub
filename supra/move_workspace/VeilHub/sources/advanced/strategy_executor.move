module veil_finance::strategy_executor {
    use std::signer;
    use std::vector;
    use veil_hub::access_control;
    use integrations::supra_autofi;

    const E_STRATEGY_NOT_FOUND: u64 = 1;
    const E_EXECUTION_FAILED: u64 = 2;

    struct Strategy has store {
        id: u64,
        name: vector<u8>,
        target_apr: u64,
        risk_level: u8,
        active: bool,
        total_allocated: u64
    }

    struct ExecutorState has key {
        strategies: vector<Strategy>,
        total_strategies: u64,
        execution_count: u64,
        last_execution: u64
    }

    public fun initialize(admin: &signer) acquires access_control::AdminRole {
        access_control::assert_admin(admin);
        move_to(admin, ExecutorState {
            strategies: vector::empty(),
            total_strategies: 0,
            execution_count: 0,
            last_execution: 0
        });
    }

    public entry fun register_strategy(
        admin: &signer,
        name: vector<u8>,
        target_apr: u64,
        risk_level: u8
    ) acquires ExecutorState, access_control::AdminRole {
        access_control::assert_admin(admin);
        let state = borrow_global_mut<ExecutorState>(@veil_finance);

        let strategy = Strategy {
            id: state.total_strategies,
            name,
            target_apr,
            risk_level,
            active: true,
            total_allocated: 0
        };

        vector::push_back(&mut state.strategies, strategy);
        state.total_strategies = state.total_strategies + 1;
    }

    public entry fun execute_strategy(
        admin: &signer,
        strategy_id: u64,
        amount: u64
    ) acquires ExecutorState, access_control::AdminRole {
        access_control::assert_admin(admin);
        access_control::assert_not_paused();

        let state = borrow_global_mut<ExecutorState>(@veil_finance);
        assert!(strategy_id < state.total_strategies, E_STRATEGY_NOT_FOUND);

        let strategy = vector::borrow_mut(&mut state.strategies, strategy_id);
        assert!(strategy.active, E_EXECUTION_FAILED);

        strategy.total_allocated = strategy.total_allocated + amount;
        state.execution_count = state.execution_count + 1;
        state.last_execution = supra_framework::timestamp::now_seconds();
    }

    public fun get_best_strategy(): u64 acquires ExecutorState {
        let state = borrow_global<ExecutorState>(@veil_finance);
        let best_id = 0;
        let best_apr = 0;
        let i = 0;

        while (i < vector::length(&state.strategies)) {
            let strategy = vector::borrow(&state.strategies, i);
            if (strategy.active && strategy.target_apr > best_apr) {
                best_apr = strategy.target_apr;
                best_id = strategy.id;
            };
            i = i + 1;
        };
        best_id
    }

    public fun get_strategy_count(): u64 acquires ExecutorState {
        let state = borrow_global<ExecutorState>(@veil_finance);
        state.total_strategies
    }
}
