pragma solidity ^0.5.0;

import "../lifecycle/Pausable.sol";
import "../roles/OrganizerRole.sol";

// mock class using Pausable
contract PausableMock is Pausable, OrganizerRole {
    constructor() public Pausable() OrganizerRole() {
        // Do nothing.
    }

    function pause() public onlyOrganizer {
        super.pause();
    }

    function unpause() public onlyOrganizer {
        super.unpause();
    }

    function onlyWorksWhenNotPaused() external whenNotPaused {
        // Do nothing. Just tests modifier
    }

    function onlyWorksWhenPaused() external whenPaused {
        // Do nothing. Just tests modifier
    }
}
