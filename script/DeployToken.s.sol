// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyGovernanceToken.sol";

contract DeployToken is Script {
    function run() external {
        uint256 deployerPK = vm.envUint("PRIVATE_KEY");
        address lzEndpoint = vm.envAddress("LZ_ENDPOINT");
        address initialOwner = vm.envAddress("TOKEN_OWNER");

        vm.startBroadcast(deployerPK);
        new MyGovernanceToken("MyGovernanceToken", "MGT", lzEndpoint, 8, initialOwner);
        vm.stopBroadcast();
    }
}
