// The MIT License(MIT)

// Copyright(c) 2016 - 2019 zOS Global Limited

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files(the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
//   distribute, sublicense, and / or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be included
//   in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Based on OpenZeppelin's https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/roles/MinterRole.sol

pragma solidity 0.5.16;

import "@openzeppelin/contracts/access/Roles.sol";

/**
    @notice Implements a access control for a Organizer role,
    which will be responsible for managing hackathons/contests.
    @dev not detailed documentation, since its based on OpenZeppelin.
    Take a look at the repo for further info.
 */
contract OrganizerRole {
    using Roles for Roles.Role;

    event OrganizerAdded(address indexed account);
    event OrganizerRemoved(address indexed account);

    Roles.Role private _organizers;

    constructor(address initialOrganizer) internal {
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

    function _addOrganizer(address account) internal {
        _organizers.add(account);
        emit OrganizerAdded(account);
    }

    function _removeOrganizer(address account) internal {
        _organizers.remove(account);
        emit OrganizerRemoved(account);
    }
}
