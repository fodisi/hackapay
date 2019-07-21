pragma solidity ^0.5.0;

import "../roles/OrganizerRole.sol";
import "../roles/JudgeRole.sol";

contract Contest is OrganizerRole, JudgeRole {
    uint256 public id;
    bytes32 public name;
    bytes32 public description;

    constructor(uint256 _id, bytes32 _name, bytes32 _description) public OrganizerRole() {
        require(name != "", "Invalid name");
        id = _id;
        name = _name;
        description = _description;
    }

    function addJudge(address account) public onlyOrganizer {
        super._addJudge(account);
    }

    function removeJudge(address account) public onlyOrganizer {
        super._removeJudge(account);
    }

    //TODO: Add Contest methods that need inheritance like voting, etc., etc.

}
