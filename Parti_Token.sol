// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract PartiCoin is ERC20,ERC20Permit {
    address  owner;
    address [] public transferers;
    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name)
    {
        _mint(address(this), 1000000 * 10 ** decimals());
         owner = msg.sender;
       
        
    }

    function addTransferer(address transferer) external{
        require(msg.sender == owner, "You do not own this contract");
     transferers.push  (transferer);  
    }

    function isAllowedToTransfer(address addr) public view returns (bool) {
    for (uint i = 0; i < transferers.length; i++) {
        if (transferers[i] == addr) {
            return true;
        }
    }
    return false;
}


    function transfer_reward(address depositor, uint amount) external{
        require (isAllowedToTransfer (msg.sender),"You are not permitted");
        _transfer(address(this), depositor, amount);
    }
}

