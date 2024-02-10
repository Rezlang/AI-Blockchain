// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2; // Specify the compiler version. This is for Solidity 0.8.0 or newer.

/**
 * @title Simple Bank
 * @dev A public bank that allows one to store and withdraw money
 */
contract SimpleBank {
    // Holds the current balance of each user
    mapping(address => uint256) public balances;

    /**
     * @dev Deposit money to the bank
     */
    function deposit() public payable {
        require (msg.value > 0);
        balances[msg.sender] += msg.value;
    }

    /**
     * @dev Withdraw money from the bank
     * @param value amount to withdraw
     */
    function withdraw(uint256 value) public {
        require (value <= balances[msg.sender]);
        balances[msg.sender] -= value;
        payable(msg.sender).transfer(value);
    }

    /**
     * @dev Get your balance
     */
    function getBalance() public view returns (uint256){
        return balances[msg.sender];
    }

    /**
     * @dev Withdraw all money in your account
     */
    function withdrawAll() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Insufficient balance");
        
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }

}

