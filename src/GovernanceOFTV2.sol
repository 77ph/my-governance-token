
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "solidity-examples/token/oft/v2/OFTV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Изменённый OFTV2 с Ownable встроенным СЮДА, а НЕ в оригинальный OFTV2
abstract contract GovernanceOFTV2 is OFTV2, Ownable {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _sharedDecimals,
        address _lzEndpoint,
        address initialOwner
    ) OFTV2(_name, _symbol, _sharedDecimals, _lzEndpoint) {
        _transferOwnership(initialOwner);
    }
}


