// SPDX-License-Identifier: UNLICENSED

// Based on OpenZeppelin's https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/mocks/MinterRoleMock.sol

pragma solidity >=0.7.0 <0.8.0;

import "../roles/AttendeeRole.sol";

contract AttendeeRoleMock is AttendeeRole {
    constructor() AttendeeRole(msg.sender) {}

    function removeAttendee(address account) public {
        _removeAttendee(account);
    }

    function onlyAttendeeMock() public view onlyAttendee {
        // solhint-disable-previous-line no-empty-blocks
    }

    // Causes a compilation error if super._removeAttendee is not internal
    function _removeAttendee(address account) internal override {
        super._removeAttendee(account);
    }
}
