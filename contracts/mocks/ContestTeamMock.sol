pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "../core/HackathonTeam.sol";

contract HackathonTeamMock is HackathonTeam {
    using SafeMath for uint256;

    // Helper testing functions.
    function getReservedBalance() public view returns (uint256) {
        return reservedBalance;
    }

    function getAvailableBalance() public view returns (uint256) {
        return address(this).balance.sub(reservedBalance);
    }
}
