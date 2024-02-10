// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2; // Specify the compiler version. This is for Solidity 0.8.0 or newer.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title NFTDutchAuction
 * @dev A dutch auction site for NFTs
 */
contract NFTDutchAuction{
    ERC721 public token;
    uint256 public startPrice; // initial auction price
    uint256 public startTime; // start time of auction
    uint256 public interval; // time interval in seconds between price decrements
    uint256 public priceChange; // change in price after each interval
    uint256 public tokenID; // id of token currently being auctioned
    uint256 public minPrice; // price that the auction will stop
    bool public acceptingBids; // auction accepts bids if true
    address public owner;
    
    constructor() {
        owner = msg.sender;
        acceptingBids = false;
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function setToken(address _token, uint256 _tokenID) public ownerOnly {
        require(_token != address(0), "Token address cannot be zero");
        token = ERC721(_token);
        require(token.ownerOf(_tokenID) == msg.sender || token.getApproved(_tokenID) == address(this), "Caller must own the token or be approved");
        token.transferFrom(msg.sender, address(this), _tokenID);
        tokenID = _tokenID;
    }

    function setStartPrice(uint256 _startPrice) public ownerOnly {
        require(_startPrice > 0, "Price must be greater than 0");
        startPrice = _startPrice;
    }

    function setInterval(uint256 _interval) public ownerOnly {
        require(_interval > 0, "Interval must be greater than 0");
        interval = _interval;
    }

    function setMinPrice(uint256 _MinPrice) public ownerOnly {
        require(_MinPrice > 0, "minPrice must be greater than 0");
        minPrice = _MinPrice;
    }

    function setPriceChange(uint256 _priceChange) public ownerOnly {
        require(_priceChange > 0, "Price change must be greater than 0");
        priceChange = _priceChange;
    }

    function checkCurrentPrice() public returns(uint256){
        uint256 elapsedIntervals = (block.timestamp - startTime) / interval;
        uint256 currentPrice = startPrice - (priceChange * elapsedIntervals);
        if (currentPrice <= minPrice) {
            acceptingBids = false;
        }
        return currentPrice;
    }

    function startAuction() public ownerOnly{
        startTime = block.timestamp;
        acceptingBids = true;
    }

    function buyNow() public payable {
        require(acceptingBids, "Auction is closed");
        uint256 currentPrice = checkCurrentPrice();
        require(msg.value >= currentPrice);
        
        // Calculate any excess ETH sent and refund it
        uint256 excessEth = msg.value - currentPrice;
        if (excessEth > 0) {
            payable(msg.sender).transfer(excessEth);
        }
        token.transferFrom(address(this), msg.sender, tokenID);
    }

    function endAuction() public ownerOnly {
        acceptingBids = false;
    }

}