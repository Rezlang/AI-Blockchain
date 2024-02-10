// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TokenSale is ReentrancyGuard {
    IERC20 public token;
    address public owner;
    uint256 public price;

    constructor(IERC20 _token, uint256 _price) {
        require(_price > 0, "Tokens per ETH must be greater than 0");

        token = _token;
        owner = msg.sender;
        price = _price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function purchase(uint256 numTokens) external payable nonReentrant {
        require(numTokens > 0, "You must purchase at least 1 token.");

        uint256 cost = numTokens * price;
        require(msg.value >= cost);

        // Check if the TokenSale contract has enough tokens
        uint256 saleBalance = token.balanceOf(address(this));
        require(saleBalance >= numTokens, "Not enough tokens in the reserve");

        // Transfer tokens to the buyer
        token.transfer(msg.sender, numTokens);

        // Refund any excess ETH
        uint256 excessAmount = msg.value - cost;
        if (excessAmount > 0) {
            payable(msg.sender).transfer(excessAmount);
        }
    }

    // Allow the owner to withdraw ETH
    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Allow the owner to withdraw tokens
    function withdrawTokens(IERC20 _token) external onlyOwner {
        require(_token.transfer(owner, _token.balanceOf(address(this))), "Failed to transfer tokens");
    }

    // Setting the price in case it needs to be updated
    function setPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, "Price must be greater than 0");
        price = _newPrice;
    }
}
