// Forge-based repo structure for MyGovernanceToken (ERC20Votes + OFT v2)

// [...previous content remains unchanged...]

// File: test/Token.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyGovernanceToken.sol";

contract TokenTest is Test {
    MyGovernanceToken token;
    address owner = address(0xABCD);
    address user = address(0xBEEF);
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        token = new MyGovernanceToken("MyGovernanceToken", "MGT", address(0x1), owner);
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

    /**
     * @dev Converts an address to bytes32.
     * @param _addr The address to convert.
     * @return The bytes32 representation of the address.
     */
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

/*
    function testSafeSend() public payable {
        vm.expectRevert();
        vm.prank(user);
        // token.safeSendFrom(user, 109, abi.encodePacked(user), 1, user, address(0), "");

        SendParam memory sendParam = SendParam(
            109, // You can also make this dynamic if needed
            addressToBytes32(user),
            1 ether,
            1 ether * 9 / 10,
            "",
            "",
            ""
        );

        MessagingFee memory fee = token.quoteSend(sendParam, false);
        token.send{value: fee.nativeFee}(sendParam, fee, msg.sender);
    }
*/

    function testDelegateTracksAfterTransfer() public {
        vm.prank(owner);
        vm.chainId(1);
        token.mint(user, 100 ether);

        vm.prank(user);
        token.delegate(user);

        uint256 votesBefore = token.getVotes(user);
        assertEq(votesBefore, 100 ether);

        vm.prank(user);
        token.burn(40 ether);

        vm.prank(owner);
        vm.chainId(1);
        token.mint(user, 40 ether);

        uint256 votesAfter = token.getVotes(user);
        assertEq(votesAfter, 100 ether);
    }

    function testDelegateToAliceThenToBobThenBack() public {
        vm.prank(owner);
        vm.chainId(1);
        token.mint(user, 100 ether);

        // User delegates to Alice
        vm.prank(user);
        token.delegate(alice);
        assertEq(token.getVotes(alice), 100 ether);

        // Burn (simulate sendFrom to other chain)
        vm.prank(user);
        token.burn(100 ether);
        assertEq(token.getVotes(alice), 0);

        // Delegate to Bob in the other chain
        vm.prank(user);
        token.delegate(bob); // on "Polygon"

        // Mint back tokens (simulate returning from other chain)
        vm.prank(owner);
        vm.chainId(1);
        token.mint(user, 100 ether);

        // Votes should go back to Alice, not Bob
        assertEq(token.getVotes(alice), 100 ether);
        assertEq(token.getVotes(bob), 0);
    }
}
