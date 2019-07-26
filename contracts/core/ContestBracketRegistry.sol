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

    bool internal avaliationEnabled;
    // bool internal submissionEnabled;

    /// @dev emitted when the avaliation process is updated. See {openAvaliation()} and {closeAvaliation()}
    event AvaliationStatusUpdated(bool enabled);
    event JudgeVoted(uint256 indexed id, address judgeAddress, bool voted);

    modifier avaliationIsOpen() {
        require(avaliationEnabled, "Avaliation is closed");
        _;
    }

    modifier avaliationIsClosed() {
        require(!avaliationEnabled, "Avaliation is open");
        _;
    }

    // ///@dev This class needs to be inherited.
    // constructor() internal {}

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
        @notice Closes the avaliation process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function closeAvaliation() external avaliationIsOpen onlyOrganizer {
        _closeAvaliation();
    }

    /**
        @notice Opens the avaliation process
        @dev Should be overwritten on inherited contract to add modifier or require statements for access control.
     */
    function openAvaliation() external avaliationIsClosed onlyOrganizer {
        _openAvaliation();
    }

    /**
        @notice Gets the avaliation status
        @return {bool} returns {true} if enabled; otherwise, {false}.
     */
    function getAvaliationStatus() external view returns (bool) {
        return avaliationEnabled;
    }

    function _closeAvaliation() internal {
        avaliationEnabled = false;
        emit AvaliationStatusUpdated(avaliationEnabled);
    }

    function _openAvaliation() internal {
        avaliationEnabled = true;
        emit AvaliationStatusUpdated(avaliationEnabled);
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
}
