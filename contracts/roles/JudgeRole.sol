// The MIT License(MIT)

// Copyright(c) 2016 - 2019 zOS Global Limited

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files(the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
//   distribute, sublicense, and / or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be included
//   in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Based on OpenZeppelin's https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

/**
    @notice Implements a access control for a Judge role,
    which will be responsible for evaluating teams' proposals.
    @dev not detailed documentation, since its based on OpenZeppelin.
    Take a look at the repo for further info.
 */
contract JudgeRole {
    using Roles for Roles.Role;

    event JudgeAdded(address indexed account);
    event JudgeRemoved(address indexed account);

    Roles.Role private _judges;

    constructor() internal {
        // Needs to be inherited.
    }

    modifier onlyJudge() {
        require(isJudge(msg.sender), "JudgeRole: caller does not have Judge Role.");
        _;
    }

    function isJudge(address account) public view returns (bool) {
        return _judges.has(account);
    }

    /// @notice
    /// @dev Needs to be implemented by a inherited contract.
    function addJudge(address account) public;

    function renounceJudge() public {
        _removeJudge(msg.sender);
    }

    function _addJudge(address account) internal {
        _judges.add(account);
        emit JudgeAdded(account);
    }

    function _removeJudge(address account) internal {
        _judges.remove(account);
        emit JudgeRemoved(account);
    }
}
