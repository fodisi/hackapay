// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "./ContestTeamRegistry.sol";
import "../roles/ContestRoleManager.sol";

/**
    @notice Controls the evaluation process by the judges and publishing of final results.
 */
abstract contract ContestBracketRegistry is ContestTeamRegistry, ContestRoleManager {
    using SafeMath for uint256;

    /// @notice Represetns a judge evaluating the teams in the contest.
    struct Judge {
        uint256 id;
        address judgeAddress;
        bool active;
        bool voted;
    }

    // Judge's helpers
    Judge[] internal judgesInfo; // List of judges
    // uint256 internal activeJudgesCount; // Controls active judges (the ones not removed)
    mapping(address => Judge) internal judgeByAddress;
    bool internal evaluationEnabled;
    Team internal firstPlace;
    Team internal secondPlace;
    Team internal thirdPlace;
    bool internal rankPublished;

    /// @dev emitted when the evaluation process is updated. See {openEvaluation()} and {closeEvaluation()}
    event EvaluationStatusUpdated(bool enabled);
    /// @dev emitted when a judge submits its evaluation.
    event JudgeVoted(uint256 indexed id, address judgeAddress);
    /// @dev emitted when winners are announced.
    event WinnerAnnouced(uint256 teamId, address teamAddress, uint256 finalGrade, uint8 rankPosition);

    modifier evaluationIsOpen() {
        require(evaluationEnabled, "Evaluation is closed");
        _;
    }

    modifier evaluationIsClosed() {
        require(!evaluationEnabled, "Evaluation is open");
        _;
    }

    modifier whenRankPublished {
        require(rankPublished, "Rank not published yet");
        _;
    }

    modifier whenRankNotPublished {
        require(!rankPublished, "Rank already published");
        _;
    }

    ///@dev This class needs to be inherited - internal visibility
    /// @param initialOrganizer Represents the organizer who owns the contest, initially.
    constructor(address initialOrganizer) ContestTeamRegistry() ContestRoleManager(initialOrganizer) {}

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

    /**
        @notice Published the ranking results of the contest.
        @dev emitts an WinnerAnnounced event for each winner (1st, 2nd, 3rd place).
     */
    function publishRank()
        external
        registrationIsClosed
        submissionIsClosed
        evaluationIsClosed
        onlyOrganizer
        whenRankNotPublished
    {
        require(approvedTeamsCount > 0, "No teams registered");
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
        emit WinnerAnnouced(firstPlace.id, firstPlace.teamAddress, firstPlace.grade, 1);
        emit WinnerAnnouced(secondPlace.id, secondPlace.teamAddress, secondPlace.grade, 2);
        emit WinnerAnnouced(thirdPlace.id, thirdPlace.teamAddress, thirdPlace.grade, 3);
    }

    /**
        @notice Gets the id of the winner teams.
        @return {uint256} First place's id
        @return {uint256} Second place's id
        @return {uint256} Third place's id
     */
    function getWinnersIds() external view returns (uint256, uint256, uint256) {
        return (firstPlace.id, secondPlace.id, thirdPlace.id);
    }

    /**
        @notice Closes the registration process
        @dev Overwritten to add modifier for access control.
     */
    function closeRegistration() external override registrationIsOpen onlyOrganizer {
        super._closeRegistration();
    }

    /**
        @notice Opens the registration process
        @dev Overwritten to add modifier for access control.
     */
    function openRegistration() external override registrationIsClosed onlyOrganizer {
        super._openRegistration();
    }

    /**
        @notice Closes the proposal submission process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function closeSubmission() external override submissionIsOpen onlyOrganizer {
        super._closeSubmission();
    }

    /**
        @notice Opens the proposal submission process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function openSubmission() external override submissionIsClosed onlyOrganizer {
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

    ///@dev internal implementation for {closeEvaluation.}
    function _closeEvaluation() internal {
        evaluationEnabled = false;
        emit EvaluationStatusUpdated(evaluationEnabled);
    }

    ///@dev internal implementation for {openEvaluation.}
    function _openEvaluation() internal {
        evaluationEnabled = true;
        emit EvaluationStatusUpdated(evaluationEnabled);
    }

    /// @dev Overrides {JudgeRole} internal method, to properly update internal storage related to team members.
    function _addJudge(address account) internal override {
        // TODO: check if can re-add previously removed judges to be added.
        // require(judgeByAddress[account].judgeAddress == address(0));
        super._addJudge(account);
        uint256 newId = judgesInfo.length;
        Judge memory judge = Judge(newId, account, true, false);
        judgesInfo.push(judge);
        judgeByAddress[account] = judge;
        // activeJudgesCount = activeJudgesCount.add(1);
    }

    /// @dev Overrides {JudgeRole} internal method, to properly update internal storage related to team members.
    function _removeJudge(address account) internal override {
        super._removeJudge(account);
        Judge storage judge = judgeByAddress[account];
        judge.active = false;
        // activeJudgesCount = activeJudgesCount.sub(1);
    }

    /**
        @notice checks if a grade is valid or not.
        @param grade {uint8} the grade to be evaluated
        @return {bool} true if valid; otherwise false
     */
    function isValidGrade(uint8 grade) internal pure returns (bool) {
        return (grade >= 0 && grade <= 10);
    }
}
