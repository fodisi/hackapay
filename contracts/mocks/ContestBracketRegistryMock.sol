// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "../core/ContestBracketRegistry.sol";

contract ContestBracketRegistryMock is ContestBracketRegistry {
    constructor() ContestBracketRegistry(msg.sender) {}

}
