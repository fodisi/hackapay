pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../roles/ContestRoleManager.sol";
import "./IContest.sol";

contract Contest is IContest, ContestRoleManager {
    using SafeMath for uint256;

    struct Team {
        uint256 id;
        bytes32 name;
        address payable teamAddress;
        bytes32 proposalData;
        bool approved;
        uint256 grade;
    }

    // Team's helpers
    mapping(uint256 => Team) internal teamById;
    Team[] public teams;
    uint256 internal approvedTeamsCount;

    uint256 public id;
    bytes32 public name;
    bytes32 public description;
    bool internal allowsRegistration;

    modifier registrationIsOpen() {
        require(allowsRegistration == true, "Registration is not allowed.");
        _;
    }

    constructor(uint256 _id, bytes32 _name, bytes32 _description) public ContestRoleManager() {
        require(_name[0] != 0, "Name cannot be empty");
        id = _id;
        name = _name;
        description = _description;
    }

    function registerTeam(bytes32 teamName, address payable teamAddress, bytes32 proposalData)
        public
        registrationIsOpen
        returns (bool)
    {
        require(teamName[0] != 0, "Team name cannot be empty");
        require(teamAddress != address(0), "");
        uint256 teamId = teams.length;
        // Teams are initialy approved. Based on expectation that most teams would be approved to participate in the contest,
        // avoiding organizers to send multiple or incurring in additional transaction cost to approve the majority of teams.
        // If needed, organizers can send transactions to reprove teams (less transactions == less cost);
        teams[teamId] = Team(teamId, teamName, teamAddress, proposalData, true, 0);
    }

}
