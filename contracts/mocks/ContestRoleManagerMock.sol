// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "../roles/ContestRoleManager.sol";

contract ContestRoleManagerMock is ContestRoleManager {
    constructor() ContestRoleManager(msg.sender) {}

    function getActiveOrganizersCount() public view returns (uint256) {
        return activeOrganizersCount;
    }

    function getActiveJudgesCount() public view returns (uint256) {
        return activeJudgesCount;
    }

}
