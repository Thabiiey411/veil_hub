module hello_blockchain::message {
    use std::error;
    use std::signer;
    use std::string;
    use supra_framework::event;
    struct MessageHolder has key {
        message: string::String,
    }
    #[event]
    struct MessageChange has drop, store {
        account: address,
        from_message: string::String,
        to_message: string::String,
    }
