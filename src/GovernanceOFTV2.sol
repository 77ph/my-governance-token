// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "solidity-examples/token/oft/v2/OFTV2.sol";

// Обёртка над OFTV2 без Ownable — всё управление будет в MyGovernanceToken
abstract contract GovernanceOFTV2 is OFTV2 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _sharedDecimals,
        address _lzEndpoint
    ) OFTV2(_name, _symbol, _sharedDecimals, _lzEndpoint) {}
}

