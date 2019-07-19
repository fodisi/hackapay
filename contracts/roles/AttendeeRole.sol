pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

contract AttendeeRole {
    using Roles for Roles.Role;

    event AttendeeAdded(address indexed account);
    event AttendeeRemoved(address indexed account);

    Roles.Role private _attendees;

    constructor() internal {
        _addAttendee(msg.sender);
    }

    modifier onlyAttendee() {
        require(isAttendee(msg.sender), "AttendeeRole: caller does not have Attendee Role.");
        _;
    }

    function isAttendee(address account) public view returns (bool) {
        return _attendees.has(account);
    }

    function addAttendee(address account) public onlyAttendee {
        _addAttendee(account);
    }

    function renounceAttendee() public {
        _removeAttendee(msg.sender);
    }

    function _addAttendee(address account) internal {
        _attendees.add(account);
        emit AttendeeAdded(account);
    }

    function _removeAttendee(address account) internal {
        _attendees.remove(account);
        emit AttendeeRemoved(account);
    }
}
