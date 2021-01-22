// Based on OpenZeppelin's https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/roles/MinterRole.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "./Roles.sol";

/**
    @notice Implements a access control for a Judge role,
    which will be responsible for evaluating teams' proposals.
    @dev not detailed documentation, since its based on OpenZeppelin.
    Take a look at the repo for further info.
 */
abstract contract JudgeRole {
    using Roles for Roles.Role;

    event JudgeAdded(address indexed account);
    event JudgeRemoved(address indexed account);

    Roles.Role private _judges;

    modifier onlyJudge() {
        require(isJudge(msg.sender), "JudgeRole: caller does not have Judge Role.");
        _;
    }

    function isJudge(address account) public view returns (bool) {
        return _judges.has(account);
    }

    /// @notice
    /// @dev Needs to be implemented by a inherited contract.
    function addJudge(address account) virtual public;

    function renounceJudge() public {
        _removeJudge(msg.sender);
    }

    function _addJudge(address account) internal virtual {
        _judges.add(account);
        emit JudgeAdded(account);
    }

    function _removeJudge(address account) internal virtual {
        _judges.remove(account);
        emit JudgeRemoved(account);
    }
}
