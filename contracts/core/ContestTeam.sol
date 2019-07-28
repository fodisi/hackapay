pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../roles/AttendeeRole.sol";
import "../payment/Payable.sol";
import "../lifecycle/Pausable.sol";

/**
 * @notice Represents a Contest Team, allowing the team to receive prizes, and members to split and withdraw their prizes.
 * @dev This contract follows the "withdraw pattern". This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {withdraw}
 * function.
 */

// Future improvements
//TODO: implement multisig to close the contract for new members.
//TODO: implement multisig to destroy the contract.
//TODO: implement multisig to remove members.
//TODO: implement multisig to transfer contract's funds to another address. See TODO on {splitPrize}.
contract ContestTeam is Payable, AttendeeRole, Pausable {
    using SafeMath for uint256;

    address[] internal teamMembers; // List of members
    uint256 internal activeTeamMembersCount; // Helper for {splitPrize} and {getActiveMembers}.
    mapping(address => bool) internal activeTeamMembers; // Controls active members
    mapping(address => uint256) internal balances; // Controls member's balances.
    uint256 internal reservedBalance; // Controls reserved balance, that was already split.

    /// @notice emitted when a member withdraws from the contract.
    event Withdraw(address indexed to, uint256 amount, uint256 indexed datetime);
    /// @notice emitted when the contract's balance (prize) is split between active members.
    event PrizeSplit(
        address indexed sender,
        uint256 totalPrize,
        uint256 membersCount,
        uint256 memberPrize,
        uint256 indexed datetime
    );

    /// @dev Needs to be inherited.
    constructor() internal Payable() AttendeeRole() Pausable() {}

    /**
     * @notice Splits the available's contract balance between active team members.
     * @dev Implements the "withdraw pattern" by allocating balances to team 
     * members, so they can request a withdraw once the split is done.
     */
    function splitPrize() external onlyAttendee whenNotPaused {
        // Cannot split amounts that were split in the past and are still pending from withdraw.
        uint256 availableBalance = address(this).balance.sub(reservedBalance);
        require(availableBalance > 0, "ContestantTeam balance is 0");

        uint256 prize = availableBalance.div(activeTeamMembersCount);
        require(prize > 0, "Member prize is 0");

        uint256 expectedDistribution = SafeMath.mul(prize, activeTeamMembersCount);
        uint256 distributedPrize;

        for (uint256 index = 0; index < teamMembers.length; index++) {
            address member = teamMembers[index];
            // Credits active member's balance.
            if (activeTeamMembers[member] == true) {
                balances[member] = balances[member].add(prize);
                distributedPrize = distributedPrize.add(prize);
            }
        }

        // Makes sure new split is reserved and accounted in future splits
        reservedBalance = reservedBalance.add(availableBalance);
        // Makes sure no invalid distribution was done between members. If so, it reverts.
        // TODO: In case there's a bug in the above logic, contract's funds could be stuck
        // in the contract. See future improvements related to multisignature implementation to mitigate
        // this issue in case a bug is found (tests do not show bugs, but untested scenarioes may rise).
        require(distributedPrize == expectedDistribution, "Invalid split between active members");
        require(address(this).balance == reservedBalance, "Reserved balanced was not updated properly");
        emit PrizeSplit(msg.sender, availableBalance, activeTeamMembersCount, prize, now);
    }

    /**
     * @notice Allows a team member to withdraw its funds from the contract.
     * @dev Implements the "withdraw pattern" allowing members to withdraw funds.
     * The method is public, so inactive members (that renounced membership)
     * are still able to withdraw funds in case balance > 0. 
     */
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Not enough balance");
        uint256 currentBalance = balances[msg.sender];
        currentBalance = currentBalance.sub(amount);
        balances[msg.sender] = currentBalance;
        // Updates contract's reserved balance, so future splits will be correctly calculated.
        reservedBalance = reservedBalance.sub(amount);
        msg.sender.transfer(amount);
        emit Withdraw(msg.sender, amount, now);
    }

    /// @notice Gets the active members in the team.
    function getActiveMembers() public view returns (address[] memory) {
        require(activeTeamMembersCount <= teamMembers.length);
        address[] memory activeMembers = new address[](activeTeamMembersCount);
        // {teamMembers} can have INACTIVE members, so need to loop through to return only active members.
        for (uint256 index = 0; index < teamMembers.length; index++) {
            address member = teamMembers[index];
            if (activeTeamMembers[member] == true) {
                activeMembers[index] = member;
            }
        }
        return activeMembers;
    }

    /// @notice Gets the number of active team members.
    function getActiveMembersCount() external view returns (uint256) {
        return activeTeamMembersCount;
    }

    /// @notice Get the balance of a team member
    function balanceOf() public view onlyAttendee returns (uint256) {
        return balances[msg.sender];
    }

    /**
        @notice Trigger the paused state.
        @dev Implements the onlyAttendee modifier for access control.
     */
    function pause() public onlyAttendee {
        super.pause();
    }

    /**
        @notice Lifts the paused state.
        @dev Implements the onlyAttendee modifier for access control.
     */
    function unpause() public onlyAttendee {
        super.unpause();
    }

    /// @dev Overrides {AttendeeRole} internal method, to properly update internal storage related to team members.
    function _addAttendee(address account) internal whenNotPaused {
        super._addAttendee(account);
        teamMembers.push(account);
        activeTeamMembers[account] = true;
        activeTeamMembersCount = activeTeamMembersCount.add(1);
    }

    /// @dev Overrides {AttendeeRole} internal method, to properly update internal storage related to team members.
    function _removeAttendee(address account) internal whenNotPaused {
        // Makes sure the contract have at least of member/owner.
        require(activeTeamMembersCount > 1, "Cannot remove last member from contract");
        super._removeAttendee(account);
        activeTeamMembers[account] = false;
        activeTeamMembersCount = activeTeamMembersCount.sub(1);
    }
}
