// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyGovernanceToken.sol";

contract TransferOwnershipToDead is Script {
    function run() external {
        uint256 deployerPK = vm.envUint("PRIVATE_KEY");
        address token = vm.envAddress("TOKEN_ADDRESS");

        vm.startBroadcast(deployerPK);
        MyGovernanceToken(token).transferOwnership(0x000000000000000000000000000000000000dEaD);
        vm.stopBroadcast();
    }
}
