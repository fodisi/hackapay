pragma solidity 0.5.16;

import "../lifecycle/Pausable.sol";
import "../roles/OrganizerRole.sol";

// mock class using Pausable
contract PausableMock is Pausable, OrganizerRole {
    constructor() public Pausable() OrganizerRole(msg.sender) {
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
