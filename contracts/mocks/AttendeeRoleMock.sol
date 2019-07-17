pragma solidity ^0.5.0;

import "../roles/AttendeeRole.sol";

contract AttendeeRoleMock is AttendeeRole {
    constructor() public AttendeeRole() {}

    function removeAttendee(address account) public {
        _removeAttendee(account);
    }

    function onlyAttendeeMock() public view onlyAttendee {
        // solhint-disable-previous-line no-empty-blocks
    }

    // Causes a compilation error if super._removeAttendee is not internal
    function _removeAttendee(address account) internal {
        super._removeAttendee(account);
    }
}
