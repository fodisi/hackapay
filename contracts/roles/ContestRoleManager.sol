// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../roles/OrganizerRole.sol";
import "../roles/JudgeRole.sol";

/**
    @notice Extends the roles OrganizerRole and JudgeRole and adds access control
    to public methods, plus controls judges and organizers accounts.
 */
abstract contract ContestRoleManager is OrganizerRole, JudgeRole {
    using SafeMath for uint256;

    // Judge's helpers
    address[] internal judges; // List of judges
    uint256 internal activeJudgesCount; // Controls active judges count
    mapping(address => bool) internal activeJudges; // Controls active judges state
    // Organizer's helpers
    address[] internal organizers; // List of organizers
    uint256 internal activeOrganizersCount; // Controls active organizers count
    mapping(address => bool) internal activeOrganizers; // Controls active organizers state

    constructor(address initialOrganizer) OrganizerRole(initialOrganizer) JudgeRole() {}

    function addJudge(address account) public override onlyOrganizer {
        _addJudge(account);
    }

    function removeJudge(address account) public onlyOrganizer {
        _removeJudge(account);
    }

    function _addJudge(address account) virtual internal override {
        super._addJudge(account);
        judges.push(account);
        activeJudges[account] = true;
        activeJudgesCount = activeJudgesCount.add(1);
    }

    function _removeJudge(address account) virtual internal override {
        super._removeJudge(account);
        activeJudges[account] = false;
        activeJudgesCount = activeJudgesCount.sub(1);
    }

    function _addOrganizer(address account) internal override {
        super._addOrganizer(account);
        organizers.push(account);
        activeOrganizers[account] = true;
        activeOrganizersCount = activeOrganizersCount.add(1);
    }

    function _removeOrganizer(address account) internal override {
        super._removeOrganizer(account);
        activeOrganizers[account] = false;
        activeOrganizersCount = activeOrganizersCount.sub(1);
    }
}
