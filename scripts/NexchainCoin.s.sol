// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {NexchainCoin} from "../src/NexchainCoin.sol";

contract DeployScript is Script {
    function run() external {
        // Get the private key from the environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        address daoMultisig = vm.envAddress("DAO_MULTISIG");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the contract
        NexchainCoin token = new NexchainCoin(daoMultisig);
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
        
        // Log the deployed address
        console2.log("NexchainCoin deployed at:", address(token));
    }
} 