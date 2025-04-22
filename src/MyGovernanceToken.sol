
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./GovernanceOFTV2.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract MyGovernanceToken is GovernanceOFTV2, ERC20Votes {
    uint8 private immutable _sharedDecimals;

    constructor(
        string memory name_,
        string memory symbol_,
        address lzEndpoint_,
        uint8 sharedDecimals_,
        address initialOwner
    )
        GovernanceOFTV2(name_, symbol_, sharedDecimals_, lzEndpoint_, initialOwner)
        ERC20Votes()
        EIP712(name_, "1")
    {
        _sharedDecimals = sharedDecimals_;
        _mint(initialOwner, 1_000_000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(block.chainid == 1, "Mint only on L1");
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
        require(amount >= minTransferable, "Too small");

        sendFrom(
            from,
            dstChainId,
            toAddress,
            amount,
            refundAddress,
            zroPaymentAddress,
            adapterParams
        );
    }

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }
}

