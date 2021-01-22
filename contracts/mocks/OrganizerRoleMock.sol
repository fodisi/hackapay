// SPDX-License-Identifier: UNLICENSED

// Based on OpenZeppelin's https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/mocks/MinterRoleMock.sol

pragma solidity >=0.7.0 <0.8.0;

import "../roles/OrganizerRole.sol";

contract OrganizerRoleMock is OrganizerRole {
    constructor() OrganizerRole(msg.sender) {}

    function removeOrganizer(address account) public {
        _removeOrganizer(account);
    }

    function onlyOrganizerMock() public view onlyOrganizer {
        // solhint-disable-previous-line no-empty-blocks
    }

    // Causes a compilation error if super._removeOrganizer is not internal
    function _removeOrganizer(address account) internal override {
        super._removeOrganizer(account);
    }
}
