// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@layerzerolabs/solidity-examples/contracts/token/oft/v2/OFTV2.sol";

contract MyGovernanceToken is OFTV2, ERC20Votes, Ownable {
    uint8 private immutable _sharedDecimals;

    event CrossChainTransferInitiated(
        address indexed from,
        uint16 indexed dstChainId,
        address indexed to,
        uint256 amount
    );

    constructor(
        string memory name_,
        string memory symbol_,
        address _lzEndpoint,
        uint8 sharedDecimals_,
        address initialOwner
    )
        OFTV2(name_, symbol_, sharedDecimals_, _lzEndpoint)
        ERC20Permit(name_)
    {
        _transferOwnership(initialOwner);
        _sharedDecimals = sharedDecimals_;
        _mint(initialOwner, 1_000_000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(block.chainid == 1, "Minting only allowed on Ethereum mainnet");
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function safeSendFrom(
        address from,
        uint16 dstChainId,
        bytes calldata toAddress,
        uint256 amount,
        address payable refundAddress,
        address zroPaymentAddress,
        bytes calldata adapterParams
    ) external payable {
        uint256 minTransferable = 10 ** (decimals() - _sharedDecimals);
        require(amount >= minTransferable, "Amount too small to cross chains");

        sendFrom(
            from,
            dstChainId,
            toAddress,
            amount,
            refundAddress,
            zroPaymentAddress,
            adapterParams
        );

        address toDecoded = abi.decode(toAddress, (address));
        emit CrossChainTransferInitiated(from, dstChainId, toDecoded, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 value)
        internal override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, value);
    }

    function _mint(address to, uint256 amount)
        internal override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
