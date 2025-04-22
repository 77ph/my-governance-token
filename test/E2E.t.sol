// Forge-based repo structure for MyGovernanceToken (ERC20Votes + OFT v2)

// [...everything from before remains unchanged...]

// File: test/E2E.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyGovernanceToken.sol";

contract E2ETest is Test {
    uint256 ethFork;
    uint256 polygonFork;

    address owner = address(0xABCD);
    address user = address(0xBEEF);
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    MyGovernanceToken tokenETH;
    MyGovernanceToken tokenPolygon;

    function setUp() public {
        ethFork = vm.createFork(vm.envString("MAINNET_RPC"));
        polygonFork = vm.createFork(vm.envString("POLYGON_RPC"));

        // Deploy token on Ethereum fork
        vm.selectFork(ethFork);
        address ethEndpoint = 0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675;
        tokenETH = new MyGovernanceToken("MyGovernanceToken", "MGT", ethEndpoint, owner);
        vm.prank(owner);
        tokenETH.transferOwnership(owner);

        // Deploy token on Polygon fork
        vm.selectFork(polygonFork);
        address polygonEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;
        tokenPolygon = new MyGovernanceToken("MyGovernanceToken", "MGT", polygonEndpoint, owner);
        vm.prank(owner);
        tokenPolygon.transferOwnership(owner);

        // Set trusted remotes for mock LayerZero routing
        vm.selectFork(ethFork);
        tokenETH.setPeer(
            109,                        // dstEid: Chain ID (LayerZero EID) of Polygon
            bytes32(uint256(uint160(address(tokenPolygon)))) // peer: адрес токена в Polygon в виде bytes32
        );

        vm.selectFork(polygonFork);
        tokenETH.setPeer(
            101,                        // dstEid: Chain ID (LayerZero EID) of Polygon
            bytes32(uint256(uint160(address(tokenETH)))) // peer: адрес токена в Polygon в виде bytes32
        );
    }

    function testCrossChainDelegateRoundTrip() public {
        // Step 1: Ethereum mint and delegate to Alice
        vm.selectFork(ethFork);
        vm.prank(owner);
        tokenETH.mint(user, 100 ether);

        vm.prank(user);
        tokenETH.delegate(alice);
        assertEq(tokenETH.getVotes(alice), 100 ether);

        // Step 2: Burn on Ethereum (simulate sendFrom)
        vm.prank(user);
        tokenETH.burn(100 ether);
        assertEq(tokenETH.getVotes(alice), 0);

        // Step 3: Mint on Polygon (simulate receive), delegate to Bob
        vm.selectFork(polygonFork);
        vm.prank(owner);
        tokenPolygon.mint(user, 100 ether);

        vm.prank(user);
        tokenPolygon.delegate(bob);
        assertEq(tokenPolygon.getVotes(bob), 100 ether);

        // Step 4: Burn on Polygon (simulate send back)
        vm.prank(user);
        tokenPolygon.burn(100 ether);
        assertEq(tokenPolygon.getVotes(bob), 0);

        // Step 5: Mint on Ethereum (simulate final receive)
        vm.selectFork(ethFork);
        vm.prank(owner);
        tokenETH.mint(user, 100 ether);

        // Final assertion: Alice has votes again
        assertEq(tokenETH.getVotes(alice), 100 ether);
        assertEq(tokenETH.getVotes(bob), 0);
    }
}
