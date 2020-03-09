pragma solidity 0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";

/**
    @notice Controls the registration of teams and the subsequent proposal submission process
    of the teams participating in a contest.
    @dev TODO: {registerTeam} to create ContestTeam contracts on blockchain and storage contract's address as {teamAddress} on Team struct.
    Future improvements:
    TODO: Add struct to identify team members.
    TODO: Possibility to request a msg.value for members to signup for contest.
    TODO: Ability to refund members once they show up to contest.
    TODO: Add mapping for team members.
 */
contract ContestTeamRegistry {
    using SafeMath for uint256;

    /// @notice Represents a team participating in a contest.
    struct Team {
        uint256 id;
        bytes32 name;
        address teamAddress;
        bytes32 proposalData;
        bool approved;
        uint256 grade; //FIXME: scale down to a smaller uint type.
    }

    // Team's helpers
    // mapping(uint256 => Team) internal teamById;
    mapping(address => Team) internal teamByAddress;
    Team[] public teams;
    uint256 internal approvedTeamsCount;
    bool internal registrationEnabled;
    bool internal submissionEnabled;

    /// @dev emitted when a new team is registered
    event TeamRegistered(uint256 indexed teamId, bytes32 teamName, address indexed teamAddress, bool approved);
    /// @dev emitted when a the registration process is updated. See {openRegistration()} and {closeRegistration()}
    event RegistrationStatusUpdated(bool enabled);
    /// @dev emitted when a the submission process is updated. See {openSubmission()} and {closeSubmission()}
    event SubmissionStatusUpdated(bool enabled);
    /// @dev emitted when a team's proposal data is updated. See {updateProposalData}
    event TeamProposalUpdated(uint256 indexed teamId, address indexed teamAddress, bytes32 proposalData);
    /// @dev emitted when a team's status is updated. See {approveTeam} and {reproveTeam}
    event TeamStatusUpdated(uint256 indexed teamId, address indexed teamAddress, bool approved);

    modifier registrationIsOpen() {
        require(registrationEnabled, "Registration is closed");
        _;
    }

    modifier registrationIsClosed() {
        require(!registrationEnabled, "Registration is open");
        _;
    }

    modifier submissionIsOpen() {
        require(submissionEnabled, "Submission is closed");
        _;
    }

    modifier submissionIsClosed() {
        require(!submissionEnabled, "Submission is open");
        _;
    }

    modifier validTeamId(uint256 teamId) {
        require(isValidTeamId(teamId), "Invalid team id");
        _;
    }

    modifier teamIsApproved(uint256 teamId) {
        require(isTeamApproved(teamId), "Team is not approved");
        _;
    }

    modifier teamIsReproved(uint256 teamId) {
        require(!isTeamApproved(teamId), "Team is not reproved.");
        _;
    }

    ///@dev This class needs to be inherited.
    constructor() internal {}

    /**
        @notice Returns the stored information of a team
        @param teamId {uint256} the team's unique identifier returned on registration
        @return {bytes32} team's name
        @return {address} team's address
        @return {bytes32} team's proposal data
        @return {bool} team's status: {true} for approved; {false} for reproved;
        @return {uint256} team's grade
     */
    function getTeam(uint256 teamId)
        public
        view
        validTeamId(teamId)
        returns (bytes32, address, bytes32, bool, uint256)
    {
        Team memory team = teams[teamId];
        return (team.name, team.teamAddress, team.proposalData, team.approved, team.grade);
    }

    /**
        @notice Returns the stored information of a team, based on a provided address
        @param teamAddress {address} the team's contract address used on registration
        @return {bytes32} team's name
        @return {address} team's address
        @return {bytes32} team's proposal data
        @return {bool} team's status: {true} for approved; {false} for reproved;
        @return {uint256} team's grade
     */
    function getTeamByAddress(address teamAddress) public view returns (bytes32, address, bytes32, bool, uint256) {
        require(teamAddress != address(0), "Invalid zero address");
        Team memory team = teamByAddress[teamAddress];
        return (team.name, team.teamAddress, team.proposalData, team.approved, team.grade);
    }

    /**
        @notice Registers a new team in the contest registry.
        @dev Registration process must be open.
        @param teamName {bytes32} team's name; required
        @param teamName {bytes32} team's name; required
        @param teamName {bytes32} team's proposal data; could be a hash for a file 
            on IPFS or for a github link; not required
     */
    function registerTeam(bytes32 teamName, address teamAddress, bytes32 proposalData)
        external
        registrationIsOpen
        returns (uint256)
    {
        require(teamName[0] != 0, "Team name cannot be empty");
        require(teamAddress != address(0), "Team address cannot be zero");
        require(teamByAddress[teamAddress].teamAddress == address(0), "Team already registered");
        uint256 teamId = teams.length;
        // Teams are initialy approved. Based on expectation that most teams would be approved to participate in the contest,
        // avoiding organizers to send multiple or incurring in additional transaction cost to approve the majority of teams.
        // If needed, organizers can send transactions to reprove teams (less transactions == less cost);
        Team memory team = Team(teamId, teamName, teamAddress, proposalData, true, 0);
        teams.push(team);
        teamByAddress[teamAddress] = teams[teamId];
        approvedTeamsCount = approvedTeamsCount.add(1);
        emit TeamRegistered(teamId, teamName, teamAddress, true);
        return teamId;
    }

    /**
        @notice Updates the proposal data for a specific team.
        @param teamId team's unique identifier; required
        @param proposalData the updated data for the team's proposal
     */
    function updateProposalData(uint256 teamId, bytes32 proposalData)
        external
        validTeamId(teamId)
        teamIsApproved(teamId)
        submissionIsOpen
    {
        Team storage team = teams[teamId];
        team.proposalData = proposalData;
        emit TeamProposalUpdated(team.id, team.teamAddress, team.proposalData);
    }

    /**
        @notice Closes the registration process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function closeRegistration() external registrationIsOpen {
        _closeRegistration();
    }

    /**
        @notice Opens the registration process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function openRegistration() external registrationIsClosed {
        _openRegistration();
    }

    /**
        @notice Gets the registration status
        @return {bool} returns {true} if enabled; otherwise, {false}.
     */
    function getRegistrationStatus() external view returns (bool) {
        return registrationEnabled;
    }

    /**
        @notice Closes the proposal submission process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function closeSubmission() external submissionIsOpen {
        _closeSubmission();
    }

    /**
        @notice Opens the proposal submission process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function openSubmission() external submissionIsClosed {
        _openSubmission();
    }

    /**
        @notice Gets the submission status
        @return {bool} returns {true} if enabled; otherwise, {false}.
     */
    function getSubmissionStatus() external view returns (bool) {
        return submissionEnabled;
    }

    /**
        @notice (re)approves a team in participating in the contest
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
        @param teamId {uint256} the ids of the teams to be approved
     */
    function approveTeam(uint256 teamId) external {
        _approveTeam(teamId);
    }

    /**
        @notice reprove teams from participating in the contest
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
        @param teamIds {uint256[]} an array containing the ids of the teams to be reproved
     */
    function reproveTeams(uint256[] calldata teamIds) external {
        _reproveTeams(teamIds);
    }

    /**
        @notice reproves a team from participating in the contest
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
        @param teamId {uint256} the ids of the teams to be reproved
     */
    function reproveTeam(uint256 teamId) external {
        _reproveTeam(teamId);
    }

    ///@dev internal implementation
    function _closeRegistration() internal {
        registrationEnabled = false;
        emit RegistrationStatusUpdated(registrationEnabled);
    }

    ///@dev internal implementation
    function _openRegistration() internal {
        registrationEnabled = true;
        emit RegistrationStatusUpdated(registrationEnabled);
    }

    function _closeSubmission() internal {
        submissionEnabled = false;
        emit SubmissionStatusUpdated(submissionEnabled);
    }

    ///@dev internal implementation
    function _openSubmission() internal {
        submissionEnabled = true;
        emit SubmissionStatusUpdated(submissionEnabled);
    }

    ///@dev internal implementation
    function _approveTeam(uint256 teamId) internal validTeamId(teamId) teamIsReproved(teamId) {
        Team storage team = teams[teamId];
        team.approved = true;
        approvedTeamsCount = approvedTeamsCount.add(1);
        emit TeamStatusUpdated(team.id, team.teamAddress, team.approved);
    }

    ///@dev internal implementation
    function _reproveTeams(uint256[] memory teamIds) internal {
        for (uint256 i = 0; i < teamIds.length; i++) {
            _reproveTeam(teamIds[i]);
        }
    }

    ///@dev internal implementation
    function _reproveTeam(uint256 teamId) internal validTeamId(teamId) teamIsApproved(teamId) {
        Team storage team = teams[teamId];
        team.approved = false;
        approvedTeamsCount = approvedTeamsCount.sub(1);
        emit TeamStatusUpdated(team.id, team.teamAddress, team.approved);
    }

    ///@dev internal implementation
    function isValidTeamId(uint256 teamId) internal view returns (bool) {
        return (teamId < teams.length);
    }

    ///@dev internal implementation
    function isTeamApproved(uint256 teamId) internal view returns (bool) {
        if (!isValidTeamId(teamId)) {
            return false;
        }

        Team memory team = teams[teamId];
        return team.approved;
    }
}
