// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

struct SendParam {
     uint32 dstEid; // Destination endpoint ID.
     bytes32 to; // Recipient address.
     uint256 amountLD; // Amount to send in local decimals.
     uint256 minAmountLD; // Minimum amount to send in local decimals.
     bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
     bytes composeMsg; // The composed message for the send() operation.
     bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.
}

struct MessagingFee {
    uint nativeFee; // gas amount in native gas token
    uint lzTokenFee; // gas amount in ZRO token
}

contract MyGovernanceToken is OFT, ERC20Votes {
    constructor(
        string memory name_,
        string memory symbol_,
        address lzEndpoint_,
        address initialOwner
    )
        OFT(name_, symbol_, lzEndpoint_, initialOwner) 
        Ownable(initialOwner)
        ERC20Votes()
        EIP712(name_, "1")
    {
        _mint(initialOwner, 1_000_000 * 10 ** decimals());
    }

    // Mint только на L1
    function mint(address to, uint256 amount) external onlyOwner {
        require(block.chainid == 1, "Mint only on L1");
        _mint(to, amount);
    }

    // Burn только свои токены
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function _update(address from, address to, uint256 value)
    internal
    override(ERC20, ERC20Votes)
{
    super._update(from, to, value);
}
}
