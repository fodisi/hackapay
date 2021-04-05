// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "../core/ContestTeamRegistry.sol";

contract ContestTeamRegistryMock is ContestTeamRegistry {
    constructor() ContestTeamRegistry() {}

    function getApprovedTeamsCount() external view returns (uint256) {
        return approvedTeamsCount;
    }

}
