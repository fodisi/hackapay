pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../roles/OrganizerRole.sol";
import "../roles/JudgeRole.sol";

contract ContestRoleManager is OrganizerRole, JudgeRole {
    using SafeMath for uint256;

    // Judge's helpers
    address[] internal judges; // List of members
    uint256 internal activeJudgesCount; // Helper for {splitPrize} and {getActiveMembers}.
    mapping(address => bool) internal activeJudges; // Controls active members
    // Organizer's helpers
    address[] internal organizers; // List of members
    uint256 internal activeOrganizersCount; // Helper for {splitPrize} and {getActiveMembers}.
    mapping(address => bool) internal activeOrganizers; // Controls active members

    constructor() internal OrganizerRole() {}

    function addJudge(address account) public onlyOrganizer {
        _addJudge(account);
    }

    function removeJudge(address account) public onlyOrganizer {
        _removeJudge(account);
    }

    function _addJudge(address account) internal {
        super._addJudge(account);
        judges.push(account);
        activeJudges[account] = true;
        activeJudgesCount = activeJudgesCount.add(1);
    }

    function _removeJudge(address account) internal {
        super._removeJudge(account);
        activeJudges[account] = false;
        activeJudgesCount = activeJudgesCount.sub(1);
    }

    function _addOrganizer(address account) internal {
        super._addOrganizer(account);
        organizers.push(account);
        activeOrganizers[account] = true;
        activeOrganizersCount = activeOrganizersCount.add(1);
    }

    function _removeOrganizer(address account) internal {
        super._removeOrganizer(account);
        activeOrganizers[account] = false;
        activeOrganizersCount = activeOrganizersCount.sub(1);
    }
}
