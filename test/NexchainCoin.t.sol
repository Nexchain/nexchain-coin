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
        vm.expectRevert("Not enough tokens to burn");
        coin.openBurn(1 + balance);
        vm.stopPrank();
    }

    function testOpenBurnRevertsIfNotOwner() public {
        vm.startPrank(user);
        vm.expectRevert(); // Ownable reverts with a standard message
        coin.openBurn(100 ether);
        vm.stopPrank();
    }

    function testOpenBurnRevertsIfZeroAmount() public {
        vm.startPrank(owner);
        vm.expectRevert("Amount to burn cannot be 0");
        coin.openBurn(0);
        vm.stopPrank();
    }

    function testOpenBurnRevertsIfAlreadyOpen() public {
        vm.startPrank(owner);
        coin.openBurn(100 ether);
        vm.expectRevert("Burn process already in timelock phase");
        coin.openBurn(100 ether);
        vm.stopPrank();
    }

    function testOpenBurnTransfersAndSetsBlock() public {
        uint256 amount = 200 ether;
        uint256 currentBlock = block.number;

        vm.startPrank(owner);
        coin.openBurn(amount);
        vm.stopPrank();

        (uint256 burnBlock, uint256 burnAmount) = coin.burnInfo();
        assertEq(burnAmount, amount);
        assertEq(burnBlock, currentBlock + 18000); // BURN_TIMELOCK_BLOCKS
    }

    function testFinishBurnRevertsIfNotOpen() public {
        vm.startPrank(owner);
        vm.expectRevert("Burn process was not initiated");
        coin.finishBurn();
        vm.stopPrank();
    }

    function testFinishBurnRevertsIfTooEarly() public {
        vm.startPrank(owner);
        coin.openBurn(100 ether);
        vm.expectRevert("Burn process is still in timelock phase");
        coin.finishBurn();
        vm.stopPrank();
    }

    function testFinishBurnWorksAfterBlocksPassed() public {
        uint256 amount = 100 ether;

        vm.startPrank(owner);
        coin.openBurn(amount);

        // Move forward the required number of blocks
        vm.roll(block.number + 18000);

        uint256 beforeTotalSupply = coin.totalSupply();
        uint256 beforeContractBalance = coin.balanceOf(address(coin));

        coin.finishBurn();
        vm.stopPrank();

        assertEq(coin.balanceOf(address(coin)), 0);
        assertEq(coin.totalSupply(), beforeTotalSupply - beforeContractBalance);
    }

    // New test for ERC20Votes functionality
    function testVotingPowerTransfer() public {
        vm.startPrank(owner);

        uint256 ownerVotesBefore = coin.getVotes(owner);
        coin.delegate(owner); // Self-delegate to activate voting power
        uint256 ownerVotesAfter = coin.getVotes(owner);

        assertEq(ownerVotesAfter - ownerVotesBefore, coin.balanceOf(owner));
        vm.stopPrank();
    }
}
