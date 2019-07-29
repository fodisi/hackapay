pragma solidity ^0.5.0;

import "../roles/ContestRoleManager.sol";

contract ContestRoleManagerMock is ContestRoleManager {
    constructor() public ContestRoleManager(msg.sender) {}

    function getActiveOrganizersCount() public view returns (uint256) {
        return activeOrganizersCount;
    }

    function getActiveJudgesCount() public view returns (uint256) {
        return activeJudgesCount;
    }

}
