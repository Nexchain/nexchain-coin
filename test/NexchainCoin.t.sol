// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {NexchainCoin} from "../src/NexchainCoin.sol";

contract NexchainCoinTest is Test {
    NexchainCoin coin;

    address owner = address(0x1);
    address user = address(0x2);

    function setUp() public {
        vm.startPrank(owner);

        coin = new NexchainCoin(owner);

        vm.stopPrank();
    }

    function testOpenBurnRevertsIfNotEnoughTokens() public {
        uint256 balance = coin.balanceOf(owner);

        vm.startPrank(owner);

        vm.expectRevert();

        coin.openBurn(1 + balance);

        vm.stopPrank();
    }

    function testOpenBurnRevertsIfNotOwner() public {
        vm.expectRevert();

        vm.startPrank(user);

        coin.openBurn(100 ether);

        vm.stopPrank();
    }

    function testOpenBurnRevertsIfZeroAmount() public {
        vm.startPrank(owner);

        vm.expectRevert("Amount cannot be 0");

        coin.openBurn(0);

        vm.stopPrank();
    }

    function testOpenBurnRevertsIfAlreadyOpen() public {
        vm.startPrank(owner);

        coin.openBurn(100 ether);

        vm.expectRevert("Already open");

        coin.openBurn(100 ether);

        vm.stopPrank();
    }

    function testOpenBurnTransfersAndSetsTimestamp() public {
        uint256 amount = 200 ether;

        vm.startPrank(owner);

        coin.openBurn(amount);

        vm.stopPrank();

        (uint256 burnTime, uint256 burnAmount) = coin.burnInfo();
        assertEq(burnAmount, amount);
        assertEq(burnTime, block.timestamp + coin.burnPreparationDuration());
    }

    function testFinishBurnRevertsIfNotOpen() public {
        vm.startPrank(owner);

        vm.expectRevert("Not open");

        coin.finishBurn();

        vm.stopPrank();
    }

    function testFinishBurnRevertsIfTooEarly() public {
        vm.startPrank(owner);

        coin.openBurn(100 ether);

        vm.expectRevert("Time has not come yet");
        coin.finishBurn();

        vm.stopPrank();
    }

    function testFinishBurnWorksAfterTimePassed() public {
        uint256 amount = 100 ether;

        vm.startPrank(owner);

        coin.openBurn(amount);

        vm.warp(block.timestamp + coin.burnPreparationDuration());

        uint256 beforeTotalSupply = coin.totalSupply();
        uint256 beforeContractBalance = coin.balanceOf(address(coin));

        coin.finishBurn();

        vm.stopPrank();

        assertEq(coin.balanceOf(address(coin)), 0);
        assertEq(coin.totalSupply(), beforeTotalSupply - beforeContractBalance);
    }
}
