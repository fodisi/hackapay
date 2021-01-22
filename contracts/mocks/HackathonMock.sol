// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "../core/Hackathon.sol";

contract HackathonMock is Hackathon {
    constructor(uint256 _id, bytes32 _name, bytes32 _description) Hackathon(_id, _name, _description, msg.sender) {
        //
    }

    function dummyAllocatePrizesMock() external onlyOrganizer {
        prizesAllocated = true;
    }

    function dummyPublishRankMock() external onlyOrganizer {
        rankPublished = true;
    }

    function getPrizeAllocationStatus() external view returns (bool) {
        return prizesAllocated;
    }
}
