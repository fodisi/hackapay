pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./ContestTeamRegistry.sol";
import "../roles/ContestRoleManager.sol";

contract ContestBracketRegistry is ContestTeamRegistry, ContestRoleManager {
    using SafeMath for uint256;

    /// @notice Represetns a team participating in a contest.
    struct Judge {
        uint256 id;
        address judgeAddress;
        bool active;
        bool voted;
    }

    // Judge's helpers
    Judge[] internal judges; // List of members
    uint256 internal activeJudgesCount; // Helper for {splitPrize} and {getActiveMembers}.
    mapping(address => Judge) internal judgeByAddress; // Controls active members
    bool internal evaluationEnabled;
    bool public rankPublished;
    Team public firstPlace;
    Team public secondPlace;
    Team public thirdPlace;

    /// @dev emitted when the evaluation process is updated. See {openEvaluation()} and {closeEvaluation()}
    event EvaluationStatusUpdated(bool enabled);
    /// @dev emitted when a judge submits s/he's evaluation.
    event JudgeVoted(uint256 indexed id, address judgeAddress);
    //TODO: check gradeSent size
    event InvalidEvaluationSent(address indexed judgeAddress, uint256 teamIdSent, uint8 gradeSent, bool teamStatus);
    /// @dev emitted when winners is announced.
    event WinnerAnnouced(uint256 teamId, address teamAddress, uint256 finalGrade, string rankPosition);

    modifier evaluationIsOpen() {
        require(evaluationEnabled, "Evaluation is closed");
        _;
    }

    modifier evaluationIsClosed() {
        require(!evaluationEnabled, "Evaluation is open");
        _;
    }

    ///@dev This class needs to be inherited.
    constructor() internal ContestTeamRegistry() ContestRoleManager() {}

    /**
        @notice Allows a judge to submit its evaluation for the teams competing in the contest. The evaluation for all
        teams must be submitted once.
        @param teamIds Array of the ids associated with each team that is going to be evaluated.
        @param teamGrades Array of the grades given by the judge for each team.
        @dev The position of teamId and teamGrade must be the same in the array.
        For example, if teamId "1" is sent at {teamIds} array position "5" (zero-based), the grade for team "1"
        must be sent at position "5" in {teamGrades} array.
     */
    function submitEvaluation(uint256[] calldata teamIds, uint8[] calldata teamGrades)
        external
        evaluationIsOpen
        onlyJudge
    {
        require(teamIds.length == teamGrades.length, "Length of teams and teamGrades arrays must be equal");
        require(
            teamIds.length == approvedTeamsCount,
            "teamsIds and grades do not match the counting of approved teams"
        );
        require(approvedTeamsCount > 0, "No approved teams to evaluate");
        Judge storage judge = judgeByAddress[msg.sender];
        require(!judge.voted, "Judge already submitted evaluation");
        for (uint256 i = 0; i < approvedTeamsCount; i++) {
            uint256 teamId = teamIds[i];
            uint8 grade = teamGrades[i];
            // FIXME: check ways to display variables in string messages.
            // require(isValidTeamId(teamId), "Invalid team id" + string(teamId));
            // require(isTeamApproved(teamId), "Team with id " + string(teamId) + "is not approved");
            // require(isValidGrade(grade), "Invalid grade" + string(grade) + "for team id " + string(teamId));
            require(isValidTeamId(teamId), "Invalid team id");
            require(isTeamApproved(teamId), "Team is not approved");
            require(isValidGrade(grade), "Invalid grade");

            Team storage team = teams[teamId];
            team.grade = team.grade.add(grade);

        }
        // Updates judge's voting status.
        judge.voted = true;
        emit JudgeVoted(judge.id, judge.judgeAddress);
    }

    function publishRank() external registrationIsClosed submissionIsClosed evaluationIsClosed onlyOrganizer {
        require(approvedTeamsCount > 0, "No teams registered");
        require(!rankPublished, "Rank already published");
        Team memory curTeam;
        Team memory tmpFirst;
        Team memory tmpSecond;
        Team memory tmpThird;

        for (uint256 i = 0; i < teams.length; i++) {
            curTeam = teams[i];
            if (!curTeam.approved || curTeam.grade < tmpThird.grade) {
                // If team is not approved, or its grade is already lower than third place, mves to the next team.
                continue;
            }

            // TODO: Known limitation for this version: Ties or draws are not properly handled, and the last
            // one to be computed will be ranked higher.
            if (curTeam.grade > tmpFirst.grade) {
                tmpThird = tmpSecond;
                tmpSecond = tmpFirst;
                tmpFirst = curTeam;
            } else if (curTeam.grade > tmpSecond.grade) {
                tmpThird = tmpSecond;
                tmpSecond = curTeam;
            } else if (curTeam.grade > tmpThird.grade) {
                tmpThird = curTeam;
            }
        }

        firstPlace = tmpFirst;
        secondPlace = tmpSecond;
        thirdPlace = tmpThird;
        rankPublished = true;
        emit WinnerAnnouced(firstPlace.id, firstPlace.teamAddress, firstPlace.grade, "first");
        emit WinnerAnnouced(secondPlace.id, secondPlace.teamAddress, secondPlace.grade, "second");
        emit WinnerAnnouced(thirdPlace.id, thirdPlace.teamAddress, thirdPlace.grade, "third");
    }

    function getWinnersIds() external view returns (uint256, uint256, uint256) {
        return (firstPlace.id, secondPlace.id, thirdPlace.id);
    }

    /**
        @notice Closes the registration process
        @dev Overwritten to add modifier for access control.
     */
    function closeRegistration() external registrationIsOpen onlyOrganizer {
        super._closeRegistration();
    }

    /**
        @notice Opens the registration process
        @dev Overwritten to add modifier for access control.
     */
    function openRegistration() external registrationIsClosed onlyOrganizer {
        super._openRegistration();
    }

    /**
        @notice Closes the proposal submission process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function closeSubmission() external submissionIsOpen onlyOrganizer {
        super._closeSubmission();
    }

    /**
        @notice Opens the proposal submission process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function openSubmission() external submissionIsClosed onlyOrganizer {
        super._openSubmission();
    }

    /**
        @notice Closes the evaluation process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function closeEvaluation() external evaluationIsOpen onlyOrganizer {
        _closeEvaluation();
    }

    /**
        @notice Opens the evaluation process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function openEvaluation() external evaluationIsClosed onlyOrganizer {
        _openEvaluation();
    }

    /**
        @notice Gets the evaluation status
        @return {bool} returns {true} if enabled; otherwise, {false}.
     */
    function getEvaluationStatus() external view returns (bool) {
        return evaluationEnabled;
    }

    function _closeEvaluation() internal {
        evaluationEnabled = false;
        emit EvaluationStatusUpdated(evaluationEnabled);
    }

    function _openEvaluation() internal {
        evaluationEnabled = true;
        emit EvaluationStatusUpdated(evaluationEnabled);
    }

    /// @dev Overrides {JudgeRole} internal method, to properly update internal storage related to team members.
    function _addJudge(address account) internal {
        // TODO: check if can re-add previously removed judges to be added.
        // require(judgeByAddress[account].judgeAddress == address(0));
        super._addJudge(account);
        uint256 id = judges.length;
        Judge memory judge = Judge(id, account, true, false);
        judges.push(judge);
        judgeByAddress[account] = judge;
        activeJudgesCount = activeJudgesCount.add(1);
    }

    /// @dev Overrides {JudgeRole} internal method, to properly update internal storage related to team members.
    function _removeJudge(address account) internal {
        super._removeJudge(account);
        Judge storage judge = judgeByAddress[account];
        judge.active = false;
        activeJudgesCount = activeJudgesCount.sub(1);
    }

    function isValidGrade(uint8 grade) internal pure returns (bool) {
        return (grade >= 0 && grade <= 10);
    }
}
