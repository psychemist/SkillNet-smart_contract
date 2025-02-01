#[starknet::contract]
pub mod ERC721Contract {
    use starknet::ContractAddress;
    use openzeppelin::token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::{access::ownable::OwnableComponent};
    use core::num::traits::Zero;
    use contract::interfaces::IErc721::IERC721;
    // use core::num::traits::zero::Zero;

    // ERC721 Components
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // ERC721 Embeddable Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // ERC721 Storage
    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        admin: ContractAddress,
        token_id: u256,
    }

    // ERC721 Events
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    // Errors
    mod Errors {
        pub const MINT_TO_ZERO: felt252 = 'ERC20: mint to 0';
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        admin: ContractAddress
    ) {
        self.admin.write(admin);
        // Update empty string to IPFS base_URI
        self.erc721.initializer("SKILLNET", "SKN", "")
    }

    #[abi(embed_v0)]
    impl IERC721Impl of IERC721<ContractState> {
        fn mint(ref self: ContractState, to: ContractAddress) -> u256 {
            assert(to.is_non_zero(), Errors::MINT_TO_ZERO);

            let token_id = self.token_id.read() + 1;
            self.erc721.mint(to, token_id);
            self.token_id.write(token_id);

            token_id
        }
    }
}
