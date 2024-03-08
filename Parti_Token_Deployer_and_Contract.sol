// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Parti_Token.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PartiDeployer {
    address public partiTokenAddress;
    address public eth_deposit_address;
    

    constructor(
        string memory name,
        string memory symbol
        
    )
        
    {
        PartiCoin token = new PartiCoin(name, symbol);
        partiTokenAddress = address(token);

        EthDeposit  eth_deposit = new EthDeposit(partiTokenAddress);
        eth_deposit_address = address(eth_deposit);

        token.addTransferer(eth_deposit_address);
       
    }
}


contract EthDeposit {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    PartiCoin public token;

    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }

    constructor(address tokenAddress) {
        token = PartiCoin(tokenAddress); // Initialize PartiCoin contract
    }

    // Mapping to track deposited ETH balances
    mapping(address => Deposit) public depositedEth;

    // Reward rate: 50,000 tokens per block
    uint256 public constant rewardRate = 5;

    // Events
    event EthDeposited(address indexed user, uint256 amount, uint256 timestamp);
    event EthWithdrawn(address indexed user, uint256 amount, uint256 duration, uint256 reward);
   
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
        token.transfer_reward(msg.sender, amount);
                

        // Update deposited amount and emit event
        emit EthWithdrawn(msg.sender, amount, duration, reward);
    }
}
