// Based on OpenZeppelin's https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/roles/MinterRole.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "./Roles.sol";

/**
    @notice Implements a access control for a Organizer role,
    which will be responsible for managing hackathons/contests.
    @dev not detailed documentation, since its based on OpenZeppelin.
    Take a look at the repo for further info.
 */
abstract contract OrganizerRole {
    using Roles for Roles.Role;

    event OrganizerAdded(address indexed account);
    event OrganizerRemoved(address indexed account);

    Roles.Role private _organizers;

    constructor(address initialOrganizer) {
        require(initialOrganizer != address(0), "Invalid zero address");
        _addOrganizer(initialOrganizer);
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

    function _addOrganizer(address account) internal virtual {
        _organizers.add(account);
        emit OrganizerAdded(account);
    }

    function _removeOrganizer(address account) internal virtual {
        _organizers.remove(account);
        emit OrganizerRemoved(account);
    }
}
