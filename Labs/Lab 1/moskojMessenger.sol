// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Owner write, public read
 * @dev Owner can update a public message. A counter stores how many message updates.
 */
contract Messenger {
    uint32 private changeCounter = 0; // A variable to store data
    string public message;
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict access to the owner only
    modifier ownerOnly() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    /**
     * @dev Owner set message
     * @param m string message to store
     */
    function store(string memory m) public ownerOnly {
        message = m;
        changeCounter++;
    }

    /**
     * @dev Return value of message
     * @return value of 'message'
     */
    function read() public view returns (string memory) {
        return message;
    }

    /**
     * @dev Get the number of times 'message' has been changed.
     * @return value of 'changeCounter'
     */
    function getCount() public view returns (uint32) {
        return changeCounter;
    }
}
