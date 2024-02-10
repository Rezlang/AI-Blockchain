// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SimpleMockNFT is ERC721 {
    uint256 private _nextTokenId = 1;

    constructor() ERC721("SimpleMockNFT", "SMN") {}

    function mint(address to) public {
        _safeMint(to, _nextTokenId++);
    }
}