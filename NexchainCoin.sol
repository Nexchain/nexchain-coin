// SPDX-License-Identifier: MIT 

/* 
   _      _ ______ _     _ 
  |  \   | |  ____|\ \  / /     _           _          
  |   \  | | |___   \ \/ /  ___| |__   __ _(_)_ __  
  | |\ \ | |  ___|   |  |  / __| '_ \ / _` | | '_ \ 
  | | \ \| | |____  / /\ \| (__| | | | (_| | | | | | 
  |_|  \___|______|/_/  \_\\___|_| |_|\__,_|_|_| |_| 
            
*/

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol"; 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol"; 
 
 
contract NexchainCoin is ERC20, ERC20Permit, ERC20Votes, Ownable { 
    event OpenBurn(uint256 burnPossibleFromTime, uint256 amount); 
 
    uint256 public burnPreparationDuration = 2 * 24 * 60 * 60; 
 
    uint256 private _burnPossibleFromTime; 
 
    constructor(address wallet)  
        ERC20("Nexchain", "NEX") 
        ERC20Permit("Nexchain") 
        Ownable(wallet)
    { 
        _mint(wallet, 2150000000000000000000000000); 
    } 
 
    function burnInfo() public view returns (uint256 possibleFromTime, uint256 amount) { 
        if (_burnPossibleFromTime != 0) { 
            possibleFromTime = _burnPossibleFromTime; 
            amount = balanceOf(address(this)); 
        } 
    } 
 
    function openBurn(uint256 amount) external onlyOwner { 
        require(_burnPossibleFromTime == 0, "Already open"); 
 
        require(amount != 0, "Amount cannot be 0"); 
 
        require(amount <= balanceOf(msg.sender), "Not enough tokens"); 
 
        transfer(address(this), amount); 
        _burnPossibleFromTime = block.timestamp + burnPreparationDuration; 
        emit OpenBurn(_burnPossibleFromTime, amount); 
 
    } 
 
    function finishBurn() external { 
        require(_burnPossibleFromTime != 0, "Not open"); 
 
        require(_burnPossibleFromTime <= block.timestamp, "Time has not come yet"); 
 
        _burn(address(this), balanceOf(address(this))); 
        _burnPossibleFromTime = 0; 
    } 
 
    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) { 
        super._update(from, to, amount); 
    } 
 
    function nonces(address owner) public view virtual override(ERC20Permit, Nonces) returns (uint256) { 
        return super.nonces(owner); 
    } 
}