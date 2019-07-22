pragma solidity ^0.5.0;

import "../core/Contest.sol";

contract ContestMock is Contest {
    constructor(uint256 _id, bytes32 _name, bytes32 _description) public Contest(_id, _name, _description) {}
    function getActiveOrganizersCount() public view returns (uint256) {
        return activeOrganizersCount;
    }

    function getActiveJudgesCount() public view returns (uint256) {
        return activeJudgesCount;
    }
}
