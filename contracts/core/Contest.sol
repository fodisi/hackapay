pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../roles/OrganizerRole.sol";
import "../roles/JudgeRole.sol";
import "./IContest.sol";

contract Contest is IContest, OrganizerRole, JudgeRole {
    using SafeMath for uint256;

    address[] internal judges; // List of members
    uint256 internal activeJudgesCount; // Helper for {splitPrize} and {getActiveMembers}.
    mapping(address => bool) internal activeJudges; // Controls active members

    address[] internal organizers; // List of members
    uint256 internal activeOrganizersCount; // Helper for {splitPrize} and {getActiveMembers}.
    mapping(address => bool) internal activeOrganizers; // Controls active members

    uint256 public id;
    bytes32 public name;
    bytes32 public description;

    constructor(uint256 _id, bytes32 _name, bytes32 _description) public OrganizerRole() JudgeRole() {
        require(_name[0] != 0, "name cannot be empty");
        id = _id;
        name = _name;
        description = _description;
    }

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
