pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "../roles/AttendeeRole.sol";

/**
 * @dev Decided not to keep an array of members and use this array to automatically
 * set the members balance in a mapping, since we allow members to renounce from the team.
 * This contract follows the "withdraw pattern". This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {withdraw}
 * function.
 */
contract HackathonTeam is AttendeeRole {
    //TODO: implement multisig to close contract for new members.
    using SafeMath for uint256;

    event Deposit(address indexed from, uint256 amount, uint256 indexed datetime);
    event Withdraw(address indexed to, uint256 amount, uint256 indexed datetime);
    event PrizeSplit(
        address indexed sender,
        uint256 totalPrize,
        uint256 membersCount,
        uint256 memberPrize,
        uint256 indexed datetime
    );

    address[] private teamMembers;
    uint256 private activeTeamMembersCount; // Helper for {splitPrize} and {getActiveMembers}.
    mapping(address => bool) private activeTeamMembers;
    mapping(address => uint256) private balances;
    uint256 private reservedBalance;

    function deposit() public payable {
        require(msg.value > 0, "msg.value must be greather than 0");
        emit Deposit(msg.sender, msg.value, now);
    }

    /**
     * @notice Splits the available's contract balance between active team members.
     * @dev Implements the "withdraw pattern" by allocating balances to team 
     * members, so they can request a withdraw later.
     */
    function splitPrize() public onlyAttendee {
        // Cannot split amounts that were split in the past and are still pending from withdraw.
        uint256 availableBalance = address(this).balance.sub(reservedBalance);
        require(availableBalance > 0, "ContestantTeam balance is 0");

        uint256 prize = availableBalance.div(activeTeamMembersCount);
        require(prize > 0, "Member prize is 0");

        uint256 expectedDistribution = SafeMath.mul(prize, activeTeamMembersCount);
        uint256 distributedPrize;

        for (uint256 index = 0; index < teamMembers.length; index++) {
            address member = teamMembers[index];
            if (activeTeamMembers[member] == true) {
                balances[member] = balances[member].add(prize);
                distributedPrize = distributedPrize.add(prize);
            }
        }

        // Makes sure new split is reserved and accounted in future splits
        reservedBalance = reservedBalance.add(availableBalance);
        // Makes sure no invalid distribution was done.
        require(distributedPrize == expectedDistribution, "Invalid split between active members");
        require(address(this).balance == reservedBalance, "Reserved balanced was not updated properly");
        emit PrizeSplit(msg.sender, availableBalance, activeTeamMembersCount, prize, now);
    }

    /**
     * @notice Allows a team member to withdraw its funds from the contract.
     * @dev Implements the "withdraw pattern" allowing members to withdraw funds.
     * Note The method is public, so inactive members (that renounced membership)
     * are still able to withdraw funds in case balance > 0. 
     */
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "No balance available");
        uint256 currentBalance = balances[msg.sender];
        currentBalance = currentBalance.sub(amount);
        balances[msg.sender] = currentBalance;
        reservedBalance = reservedBalance.sub(amount);
        msg.sender.transfer(amount);
        emit Withdraw(msg.sender, amount, now);
    }

    function getActiveMembers() public view returns (address[] memory) {
        require(activeTeamMembersCount <= teamMembers.length);
        address[] memory activeMembers = new address[](activeTeamMembersCount);
        for (uint256 index = 0; index < teamMembers.length; index++) {
            address member = teamMembers[index];
            if (activeTeamMembers[member] == true) {
                activeMembers[index] = member;
            }
        }
        return activeMembers;
    }

    function getActiveMembersCount() public view returns (uint256) {
        return activeTeamMembersCount;
    }

    function balanceOf() public view onlyAttendee returns (uint256) {
        return balances[msg.sender];
    }

    function _addAttendee(address account) internal {
        // Avoids a member add a new address that s/he owns to withdraw funds from other members.
        super._addAttendee(account);
        teamMembers.push(account);
        activeTeamMembers[account] = true;
        activeTeamMembersCount = activeTeamMembersCount.add(1);
    }

    function _removeAttendee(address account) internal {
        require(activeTeamMembersCount > 1, "Cannot remove last member from contract");
        super._removeAttendee(account);
        activeTeamMembers[account] = false;
        activeTeamMembersCount = activeTeamMembersCount.sub(1);
    }

}
