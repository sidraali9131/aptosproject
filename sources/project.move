module MyModule::Escrow {

    use aptos_framework::coin;
    use aptos_framework::aptos_coin::{AptosCoin};
    use aptos_framework::signer;

    struct Escrow has store, key, drop {
        buyer: address,
        seller: address,
        amount: u64,
        buyer_approval: bool,
        seller_approval: bool,
    }

    // Function to create an escrow by the buyer, locking tokens
    public fun create_escrow(buyer: &signer, seller: address, amount: u64) {
        coin::transfer<AptosCoin>(buyer, signer::address_of(buyer), amount);
        move_to(buyer, Escrow {
            buyer: signer::address_of(buyer),
            seller,
            amount,
            buyer_approval: false,
            seller_approval: false,
        });
    }

    // Function to release the escrow when both buyer and seller approve
    public fun release_escrow(buyer: &signer, seller: &signer) acquires Escrow {
        let escrow = borrow_global_mut<Escrow>(signer::address_of(buyer));
        assert!(escrow.seller == signer::address_of(seller), 1);
        escrow.buyer_approval = true;
        escrow.seller_approval = true;
        
        if (escrow.buyer_approval && escrow.seller_approval) {
            coin::transfer<AptosCoin>(buyer, escrow.seller, escrow.amount);
            move_from<Escrow>(signer::address_of(buyer));
        }
    }
}
