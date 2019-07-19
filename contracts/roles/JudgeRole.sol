pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

contract JudgeRole {
    using Roles for Roles.Role;

    event JudgeAdded(address indexed account);
    event JudgeRemoved(address indexed account);

    Roles.Role private _judges;

    constructor() internal {
        // Needs to be inherited.
        // TODO: remove _addJudge
        _addJudge(msg.sender);
    }

    modifier onlyJudge() {
        require(isJudge(msg.sender), "JudgeRole: caller does not have Judge Role.");
        _;
    }

    function isJudge(address account) public view returns (bool) {
        return _judges.has(account);
    }

    // TODO: Refactor to allow only organizers to do judges.
    function addJudge(address account) public onlyJudge {
        _addJudge(account);
    }

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
