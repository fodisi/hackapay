// Based on OpenZeppelin's https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/roles/MinterRole.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "./Roles.sol";

/**
    @notice Implements a access control for an Attendee role,
    which will registering ant attending hackathons/contests.
    @dev not detailed documentation, since its based on OpenZeppelin.
    Take a look at the repo for further info.
 */
abstract contract AttendeeRole {
    using Roles for Roles.Role;

    event AttendeeAdded(address indexed account);
    event AttendeeRemoved(address indexed account);

    Roles.Role private _attendees;

    constructor(address initialAttendee) {
        require(initialAttendee != address(0), "Invalid zero address");
        _addAttendee(initialAttendee);
    }

    modifier onlyAttendee() {
        require(isAttendee(msg.sender), "AttendeeRole: caller does not have Attendee Role.");
        _;
    }

    function isAttendee(address account) public view returns (bool) {
        return _attendees.has(account);
    }

    function addAttendee(address account) virtual public onlyAttendee {
        _addAttendee(account);
    }

    function renounceAttendee() virtual public {
        _removeAttendee(msg.sender);
    }

    function _addAttendee(address account) virtual internal {
        _attendees.add(account);
        emit AttendeeAdded(account);
    }

    function _removeAttendee(address account) virtual internal {
        _attendees.remove(account);
        emit AttendeeRemoved(account);
    }
}
