pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

contract OrganizerRole {
    using Roles for Roles.Role;

    event OrganizerAdded(address indexed account);
    event OrganizerRemoved(address indexed account);

    Roles.Role private _organizers;

    constructor() internal {
        _addOrganizer(msg.sender);
    }

    modifier onlyOrganizer() {
        require(isOrganizer(msg.sender), "OrganizerRole: caller does not have Organizer Role.");
        _;
    }

    function isOrganizer(address account) public view returns (bool) {
        return _organizers.has(account);
    }

    function addOrganizer(address account) public onlyOrganizer {
        _addOrganizer(account);
    }

    function renounceOrganizer() public {
        _removeOrganizer(msg.sender);
    }

    function _addOrganizer(address account) internal {
        _organizers.add(account);
        emit OrganizerAdded(account);
    }

    function _removeOrganizer(address account) internal {
        _organizers.remove(account);
        emit OrganizerRemoved(account);
    }
}
