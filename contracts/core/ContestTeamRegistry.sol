pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract ContestTeamRegistry {
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
    bool internal submissionEnabled;

    modifier registrationIsOpen() {
        require(registrationEnabled, "Registration is closed.");
        _;
    }

    modifier registrationIsClosed() {
        require(!registrationEnabled, "Registration is open.");
        _;
    }

    modifier submissionIsOpen() {
        require(submissionEnabled, "Submission is closed.");
        _;
    }

    modifier submissionIsClosed() {
        require(!submissionEnabled, "Submission is open.");
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

    constructor() internal {}

    function getTeam(uint256 teamId)
        public
        view
        isValidTeamId(teamId)
        returns (bytes32, address payable, bytes32, bool, uint256)
    {
        Team memory team = teams[teamId];
        return (team.name, team.teamAddress, team.proposalData, team.approved, team.grade);
    }

    function registerTeam(bytes32 teamName, address payable teamAddress, bytes32 proposalData)
        external
        registrationIsOpen
        returns (uint256)
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
        return teamId;
    }

    function updateProposalData(uint256 teamId, bytes32 proposalData)
        external
        isValidTeamId(teamId)
        teamIsApproved(teamId)
        submissionIsOpen
    {
        Team storage team = teams[teamId];
        team.proposalData = proposalData;
    }

    /// @dev Should be overriten on inherited contract to add modifier or require statements for access control.
    function closeRegistration() external registrationIsOpen {
        _closeRegistration();
    }

    /// @dev Should be overriten on inherited contract to add modifier or require statements for access control.
    function openRegistration() external registrationIsClosed {
        _openRegistration();
    }

    function getRegistrationStatus() external view returns (bool) {
        return registrationEnabled;
    }

    /// @dev Should be overriten on inherited contract to add modifier or require statements for access control.
    function closeSubmission() external submissionIsOpen {
        _closeSubmission();
    }

    /// @dev Should be overriten on inherited contract to add modifier or require statements for access control.
    function openSubmission() external submissionIsClosed {
        _openSubmission();
    }

    function getSubmissionStatus() external view returns (bool) {
        return submissionEnabled;
    }

    /// @dev Should be overriten on inherited contract to add modifier or require statements for access control.
    function aproveTeam(uint256 teamId) external {
        _approveTeam(teamId);
    }

    /// @dev Should be overriten on inherited contract to add modifier or require statements for access control.
    function reproveTeams(uint256[] calldata teamIds) external {
        _reproveTeams(teamIds);
    }

    /// @dev Should be overriten on inherited contract to add modifier or require statements for access control.
    function reproveTeam(uint256 teamId) external {
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

    function _closeSubmission() internal {
        submissionEnabled = false;
    }

    function _openSubmission() internal {
        submissionEnabled = true;
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
