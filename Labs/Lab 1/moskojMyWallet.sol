// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyWallet {
    address public owner;
    address[] public guardians;
    mapping(address => bool) public isGuardian;
    mapping(address => uint256) public allowances;
    mapping(address => bool) private guardianVotes;
    uint256 public constant guardianRequirement = 3;

    struct OwnerChangeProposal {
        address proposedNewOwner;
        uint256 votes;
    }
    OwnerChangeProposal private currentProposal;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event GuardianChanged(address indexed guardian, bool isAdded);
    event AllowanceChanged(address indexed account, uint256 newAllowance);
    event NewOwnerProposal(address indexed proposedNewOwner, uint256 votes);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyGuardian() {
        require(isGuardian[msg.sender], "Only a guardian can perform this action.");
        _;
    }

    constructor(address[] memory _guardians) {
        // Owner must add allowances after creation via setAllowance()
        require(_guardians.length == 5, "Must initialize with 5 guardians.");
        owner = msg.sender;
        for (uint i = 0; i < _guardians.length; i++) {
            require(_guardians[i] != address(0), "Guardian address cannot be zero.");
            require(_guardians[i] != owner, "Owner cannot be guardian");
            guardians.push(_guardians[i]);
            isGuardian[_guardians[i]] = true;
        }
    }

    receive() external payable {}

    function spend(address payable _to, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Insufficient balance.");
        require(_amount <= allowances[_to], "Amount exceeds allowance.");
        if (allowances[_to] > 0) {
            allowances[_to] -= _amount;
        }
        _to.transfer(_amount);
    }

    function getAllowance(address person) public view returns (uint256) {
        return allowances[person];
    }

    function proposeNewOwner(address _newOwner) public onlyGuardian {
        require(_newOwner != address(0), "New owner cannot be zero address.");
        require(_newOwner != owner, "New owner must be different.");
        for (uint i = 0; i < guardians.length; i++) {
            require(guardians[i] != _newOwner, "New owner cannot be a guardian.");
        }
        
        // If this is a new proposal or the same as the current one, reset/increment votes
        if (currentProposal.proposedNewOwner != _newOwner) {
            currentProposal = OwnerChangeProposal(_newOwner, 1);
            guardianVotes[msg.sender] = true; // Record that this guardian voted for this proposal
        } else if (!guardianVotes[msg.sender]) { // Increment vote if this guardian hasn't already voted for this proposal
            currentProposal.votes += 1;
            guardianVotes[msg.sender] = true;
        }

        emit NewOwnerProposal(_newOwner, currentProposal.votes);

        // Check if the proposal has enough votes to change the owner
        if (currentProposal.votes >= guardianRequirement) {
            emit OwnershipTransferred(owner, _newOwner);
            owner = _newOwner;
            // Reset proposal and votes
            for (uint i = 0; i < guardians.length; i++) {
                guardianVotes[guardians[i]] = false;
            }
            delete currentProposal;
        }
    }

    function setAllowance(address _person, uint256 _amount) public onlyOwner {
        require(!isGuardian[_person], "Guardian cannot receive an allowance.");
        allowances[_person] = _amount;
        emit AllowanceChanged(_person, _amount);
    }

    function addOrRemoveGuardian(address _guardian, bool _isAdding) public onlyOwner {
        //Undefined behaviour when the total number of guardians is not 5.
        require(_guardian != address(0), "Guardian address cannot be zero.");
        require(isGuardian[_guardian] != _isAdding, "Guardian status already set.");
        
        isGuardian[_guardian] = _isAdding;
        if (_isAdding) {
            guardians.push(_guardian);
        } else {
            for (uint i = 0; i < guardians.length; i++) {
                if (guardians[i] == _guardian) {
                    guardians[i] = guardians[guardians.length - 1];
                    guardians.pop();
                    break;
                }
            }
        }

        emit GuardianChanged(_guardian, _isAdding);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
