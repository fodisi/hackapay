// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../core/ContestTeam.sol";

contract ContestTeamMock is ContestTeam {
    using SafeMath for uint256;

    constructor() ContestTeam(msg.sender) {}

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
