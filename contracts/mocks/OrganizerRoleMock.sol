pragma solidity ^0.5.0;

import "../roles/OrganizerRole.sol";

contract OrganizerRoleMock is OrganizerRole {
    constructor() public OrganizerRole() {}

    function removeOrganizer(address account) public {
        _removeOrganizer(account);
    }

    function onlyOrganizerMock() public view onlyOrganizer {
        // solhint-disable-previous-line no-empty-blocks
    }

    // Causes a compilation error if super._removeOrganizer is not internal
    function _removeOrganizer(address account) internal {
        super._removeOrganizer(account);
    }
}
