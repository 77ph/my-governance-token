// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyGovernanceToken.sol";

contract TokenTest is Test {
    MyGovernanceToken token;
    address owner = address(0xABCD);
    address user = address(0xBEEF);

    function setUp() public {
        token = new MyGovernanceToken("MyGovernanceToken", "MGT", address(0x1), 8, owner);
        vm.prank(owner);
        token.transferOwnership(owner);
    }

    function testMintOnlyL1() public {
        vm.prank(owner);
        vm.chainId(1); // simulate Ethereum mainnet
        token.mint(user, 100 ether);
        assertEq(token.balanceOf(user), 100 ether);
    }

    function testBurn() public {
        vm.prank(owner);
        vm.chainId(1);
        token.mint(user, 10 ether);

        vm.prank(user);
        token.burn(4 ether);

        assertEq(token.balanceOf(user), 6 ether);
    }

    function testSafeSendTooSmall() public {
        vm.expectRevert();
        vm.prank(user);
        token.safeSendFrom(user, 109, abi.encodePacked(user), 1, user, address(0), "");
    }
}
