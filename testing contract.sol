// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PartiCoin is ERC20,ERC20Permit {
    constructor() ERC20("PartiCoin", "PRTY") ERC20Permit("PartiCoin")
    {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract EthDeposit {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }

    // Mapping to track deposited ETH balances
    mapping(address => Deposit) public depositedEth;

// Reward rate: 50,000 tokens per block
    uint256 public constant rewardRate = 50000;

    // Events
    event EthDeposited(address indexed user, uint256 amount, uint256 timestamp);
    event EthWithdrawn(address indexed user, uint256 amount, uint256 duration);
   
    // Function to deposit ETH
    function depositEth() external payable {
        require(msg.value > 0, "Cannot deposit zero ETH");

        depositedEth[msg.sender] = Deposit(msg.value, block.timestamp);

        emit EthDeposited(msg.sender, msg.value, block.timestamp);
    }

    // Function to withdraw deposited ETH
   function withdrawEth(uint256 amount) external {
        Deposit storage deposit = depositedEth[msg.sender];
        require(deposit.amount > 0, "No ETH deposited");
        require(amount > 0 && amount <= deposit.amount, "Invalid withdrawal amount");

        uint256 duration = block.timestamp - deposit.timestamp;
        uint256 reward = duration.mul(rewardRate);
        payable(msg.sender).transfer(amount);
        // Distribute rewards
        if (reward > 0) {
            PartiCoin.safeTransfer(msg.sender, reward);
        }

        // Update deposited amount and emit event
        PartiCoin.amount = deposit.amount.sub(amount);
        emit EthWithdrawn(msg.sender, amount, duration, reward);
    }
    }


