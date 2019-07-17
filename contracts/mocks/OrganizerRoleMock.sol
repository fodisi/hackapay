pragma solidity ^0.5.0;

import "../roles/OrganizerRole.sol";

contract OrganizerRoleMock is OrganizerRole {
    constructor() public OrganizerRole() {}
}
