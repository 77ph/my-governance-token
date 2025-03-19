// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyGovernanceToken.sol";

contract SetTrustedRemote is Script {
    function run() external {
        uint256 deployerPK = vm.envUint("PRIVATE_KEY");
        address token = vm.envAddress("TOKEN_ADDRESS");
        uint16 remoteChainId = uint16(vm.envUint("REMOTE_CHAIN_ID"));
        address remoteToken = vm.envAddress("REMOTE_TOKEN_ADDRESS");
        address localToken = token;

        vm.startBroadcast(deployerPK);
        MyGovernanceToken(token).setTrustedRemote(
            remoteChainId,
            abi.encodePacked(remoteToken, localToken)
        );
        vm.stopBroadcast();
    }
}
