// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyGovernanceToken.sol";
import {SendParam, MessagingFee} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";

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
        vm.chainId(1);
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

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function testSendWorks() public payable {
        uint256 amount = 1 ether;

        // Подготовка SendParam
        SendParam memory param = SendParam({
            dstEid: 109,
            to: addressToBytes32(user),
            amountLD: amount,
            minAmountLD: amount * 9 / 10,
            extraOptions: "",
            composeMsg: "",
            oftCmd: ""
        });

        // Предварительно mint
        vm.prank(owner);
        vm.chainId(1);
        token.mint(owner, amount);

        // Апрув для контракта (если approvalRequired == true)
        vm.prank(owner);
        token.approve(address(token), amount);

        // Получаем fee
        MessagingFee memory fee = token.quoteSend(param, false);

        // Отправка
        vm.prank(owner);
        token.send{value: fee.nativeFee}(param, fee, payable(owner));

        // Здесь можно добавить assert по getVotes / балансу и т.д.
    }

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

        vm.prank(user);
        token.delegate(alice);
        assertEq(token.getVotes(alice), 100 ether);

        vm.prank(user);
        token.burn(100 ether);
        assertEq(token.getVotes(alice), 0);

        vm.prank(user);
        token.delegate(bob);

        vm.prank(owner);
        vm.chainId(1);
        token.mint(user, 100 ether);
        assertEq(token.getVotes(alice), 100 ether);
        assertEq(token.getVotes(bob), 0);
    }
}
