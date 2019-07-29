pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "../core/ContestTeam.sol";

contract ContestTeamMock is ContestTeam {
    using SafeMath for uint256;

    constructor() public ContestTeam() {}

    // Helper testing functions.
    function getReservedBalance() public view returns (uint256) {
        return reservedBalance;
    }

    function getAvailableBalance() public view returns (uint256) {
        return address(this).balance.sub(reservedBalance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
