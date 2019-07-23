pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../roles/ContestRoleManager.sol";

contract ContestTeamRegistry is ContestRoleManager {
    using SafeMath for uint256;

    //TODO: Add struct to identify team members.
    //TODO: Possibility to request a msg.value for members to signup for contest.
    //TODO: Ability to refund members once they show up to contest.

    //TODO: Add mapping for team members.
    struct Team {
        uint256 id;
        bytes32 name;
        address payable teamAddress;
        bytes32 proposalData;
        bool approved;
        uint256 grade;
    }

    // Team's helpers
    // mapping(uint256 => Team) internal teamById;
    mapping(address => Team) internal teamByAddress;
    Team[] public teams;
    uint256 internal approvedTeamsCount;

    bool internal registrationEnabled;

    modifier registrationIsOpen() {
        require(registrationEnabled, "Registration is closed.");
        _;
    }

    modifier registrationIsClosed() {
        require(!registrationEnabled, "Registration is open.");
        _;
    }

    modifier isValidTeamId(uint256 teamId) {
        require(teamId < teams.length, "Invalid team id");
        _;
    }

    modifier teamIsApproved(uint256 teamId) {
        Team storage team = teams[teamId];
        require(team.approved, "Team is not approved.");
        _;
    }

    modifier teamIsReproved(uint256 teamId) {
        Team storage team = teams[teamId];
        require(team.approved, "Team is not reproved.");
        _;
    }

    constructor() internal ContestRoleManager() {}

    function registerTeam(bytes32 teamName, address payable teamAddress, bytes32 proposalData)
        external
        registrationIsOpen
    {
        require(teamName[0] != 0, "Team name cannot be empty");
        require(teamAddress != address(0), "");
        uint256 teamId = teams.length;
        // Teams are initialy approved. Based on expectation that most teams would be approved to participate in the contest,
        // avoiding organizers to send multiple or incurring in additional transaction cost to approve the majority of teams.
        // If needed, organizers can send transactions to reprove teams (less transactions == less cost);
        teams[teamId] = Team(teamId, teamName, teamAddress, proposalData, true, 0);
        teamByAddress[teamAddress] = teams[teamId];
        approvedTeamsCount = approvedTeamsCount.add(1);
    }

    function updateProposalData(uint256 teamId, bytes32 proposalData)
        external
        isValidTeamId(teamId)
        teamIsApproved(teamId)
    {
        Team storage team = teams[teamId];
        team.proposalData = proposalData;
    }

    function closeRegistration() external onlyOrganizer registrationIsOpen {
        _closeRegistration();
    }

    function openRegistration() external onlyOrganizer registrationIsClosed {
        _openRegistration();
    }

    function aproveTeam(uint256 teamId) external onlyOrganizer {
        _approveTeam(teamId);
    }

    function reproveTeams(uint256[] calldata teamIds) external onlyOrganizer {
        _reproveTeams(teamIds);
    }

    function reproveTeam(uint256 teamId) external onlyOrganizer {
        _reproveTeam(teamId);
    }

    function _approveTeam(uint256 teamId) internal isValidTeamId(teamId) teamIsReproved(teamId) {
        Team storage team = teams[teamId];
        team.approved = true;
        approvedTeamsCount = approvedTeamsCount.add(1);
    }

    function _closeRegistration() internal {
        registrationEnabled = false;
    }

    function _openRegistration() internal {
        registrationEnabled = true;
    }

    function _reproveTeams(uint256[] memory teamIds) internal {
        for (uint256 i = 0; i < teamIds.length; i++) {
            _reproveTeam(teamIds[i]);
        }
    }

    function _reproveTeam(uint256 teamId) internal isValidTeamId(teamId) teamIsApproved(teamId) {
        Team storage team = teams[teamId];
        team.approved = false;
        approvedTeamsCount = approvedTeamsCount.sub(1);
    }

}
