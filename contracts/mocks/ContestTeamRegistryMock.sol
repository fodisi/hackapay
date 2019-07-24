pragma solidity ^0.5.0;

import "../core/ContestTeamRegistry.sol";

contract ContestTeamRegistryMock is ContestTeamRegistry {
    constructor() public ContestTeamRegistry() {}

    function getApprovedTeamsCount() external view returns (uint256) {
        return approvedTeamsCount;
    }

    function getRegistrationStatus() external view returns (bool) {
        return registrationEnabled;
    }

    function getSubmissionStatus() external view returns (bool) {
        return submissionEnabled;
    }

}
