// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FederatedLearningAggregator {
    struct Participant {
        uint256[] contributions;
    }

    mapping(address => Participant) private participants;
    address[] private participantAddresses;
    address private owner;

    event ParticipantAdded(address participant);
    event ParametersUpdated(address participant);
    event ContributionsConcatenated(uint256[] concatenatedContributions);

    constructor() {
        owner = msg.sender;
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "Owner only");
        _;
    }

    function addParticipant() external {
        require(participants[msg.sender].contributions.length == 0, "Participant already exists.");
        participantAddresses.push(msg.sender);
        emit ParticipantAdded(msg.sender);
    }

    function updateParticipantParameters(uint256[] calldata _contributions) external {
        require(participants[msg.sender].contributions.length != 0, "Participant does not exist.");
        participants[msg.sender].contributions = _contributions;
        emit ParametersUpdated(msg.sender);
    }

    function getParticipantContributions(address participant) external view returns (uint256[] memory) {
        return participants[participant].contributions;
    }

    function aggregateContributions() external ownerOnly returns (uint256[] memory){
        uint256 totalLength = 0;

        for (uint256 i = 0; i < participantAddresses.length; i++) {
            totalLength += participants[participantAddresses[i]].contributions.length;
        }

        uint256[] memory concatenatedContributions = new uint256[](totalLength);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < participantAddresses.length; i++) {
            uint256[] memory currentContributions = participants[participantAddresses[i]].contributions;
            for (uint256 j = 0; j < currentContributions.length; j++) {
                concatenatedContributions[currentIndex++] = currentContributions[j];
            }
        }

        emit ContributionsConcatenated(concatenatedContributions);
        return concatenatedContributions;
    }
}
