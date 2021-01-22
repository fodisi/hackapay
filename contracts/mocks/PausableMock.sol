// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "../lifecycle/Pausable.sol";
import "../roles/OrganizerRole.sol";

// mock class using Pausable
contract PausableMock is Pausable, OrganizerRole {
    constructor() Pausable() OrganizerRole(msg.sender) {
        // Do nothing.
    }

    function pause() public onlyOrganizer override {
        super.pause();
    }

    function unpause() public onlyOrganizer override {
        super.unpause();
    }

    function onlyWorksWhenNotPaused() external whenNotPaused {
        // Do nothing. Just tests modifier
    }

    function onlyWorksWhenPaused() external whenPaused {
        // Do nothing. Just tests modifier
    }
}
