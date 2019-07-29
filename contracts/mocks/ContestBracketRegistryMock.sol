pragma solidity ^0.5.0;

import "../core/ContestBracketRegistry.sol";

contract ContestBracketRegistryMock is ContestBracketRegistry {
    constructor() public ContestBracketRegistry(msg.sender) {}

    function getActiveJudgeCount() external view returns (uint256) {
        return activeJudgesCount;
    }

}
