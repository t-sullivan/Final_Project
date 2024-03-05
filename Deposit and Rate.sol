// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract EthDeposit {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Mapping to track deposited ETH balances
    mapping(address => uint256) public depositedEthBalance;


    // Mapping to track deposited token balances
    mapping(address => uint256) public depositedTokenBalance;

    // Events
    event EthDeposited(address indexed user, uint256 amount);
    event EthWithdrawn(address indexed user, uint256 amount);
    
    // Function to deposit ETH
    function depositEth() external payable {
        require(msg.value > 0, "Cannot deposit zero ETH");

        depositedEthBalance[msg.sender] = depositedEthBalance[msg.sender].add(msg.value);

        emit EthDeposited(msg.sender, msg.value);
    }

    // Function to withdraw deposited ETH
    function withdrawEth(uint256 amount) external {
        require(amount > 0, "Cannot withdraw zero ETH");
        require(depositedEthBalance[msg.sender] >= amount, "Insufficient deposited ETH balance");

        depositedEthBalance[msg.sender] = depositedEthBalance[msg.sender].sub(amount);
        payable(msg.sender).transfer(amount);

        emit EthWithdrawn(msg.sender, amount);
    }

    
}
