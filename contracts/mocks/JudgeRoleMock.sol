// SPDX-License-Identifier: UNLICENSED

// Based on OpenZeppelin's https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/mocks/MinterRoleMock.sol

pragma solidity >=0.7.0 <0.8.0;

import "../roles/JudgeRole.sol";

contract JudgeRoleMock is JudgeRole {
    constructor() JudgeRole() {
        super._addJudge(msg.sender);
    }

    function addJudge(address account) public override onlyJudge {
        super._addJudge(account);
    }

    function removeJudge(address account) public {
        _removeJudge(account);
    }

    function onlyJudgeMock() public view onlyJudge {
        // solhint-disable-previous-line no-empty-blocks
    }

    // Causes a compilation error if super._removeJudge is not internal
    function _removeJudge(address account) internal override {
        super._removeJudge(account);
    }
}
