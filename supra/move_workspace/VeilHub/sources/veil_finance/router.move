module veil_finance::router {
    use std::signer;
    use supra_framework::coin;
    use veil_finance::amm;

    public fun swap<X, Y>(account: &signer, amount_in: u64): u64 {
        amm::swap<X, Y>(account, amount_in, 0);
        amount_in // Simplified - return amount
    }
}
