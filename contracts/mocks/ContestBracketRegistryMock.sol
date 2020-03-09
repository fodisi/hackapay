pragma solidity 0.5.16;

import "../core/ContestBracketRegistry.sol";

contract ContestBracketRegistryMock is ContestBracketRegistry {
    constructor() public ContestBracketRegistry(msg.sender) {}

}
