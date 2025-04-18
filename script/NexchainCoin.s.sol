// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {NexchainCoin} from "../src/NexchainCoin.sol";

contract NexchainCoinScript is Script {
    function run() external {
        address daoMultisig = vm.envAddress("DAO_MULTISIG");
        
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Deploy the contract
        NexchainCoin token = new NexchainCoin(daoMultisig);
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
        
        // Log the deployed address
        console.log("NexchainCoin deployed at:", address(token));
    }
} 