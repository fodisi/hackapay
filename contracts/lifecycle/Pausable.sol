// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism (Circuir Breaker) that should be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of the inheritd contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 *
 * IMPORTANT: The inherited contract should override the methods {pause} and {unpause}
 * to add validations regarding access control (onlyOraganizer, onlyJudge, or any other
 * access control rule needded) to avoid the inherited contract being paused/unpaused
 * by unauthorized parties.
 */
abstract contract Pausable {
    /// @dev emitted when the pause is triggered.
    event Paused(address account);

    /// @dev emitted when the pause is lifted.
    event Unpaused(address account);

    bool private _paused;

    /// @dev Initializes the contract in unpaused state.
    constructor() {
        _paused = false;
    }

    /**
        @notice Returns if the contract is paused or not.
        @return {true} if the contract is paused; otherwise, {false}.
     */

    function isPaused() public view returns (bool) {
        return _paused;
    }

    /// @dev Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }

    /// @dev Modifier to make a function callable only when the contract is paused.
    modifier whenPaused() {
        require(_paused, "Contract is not paused");
        _;
    }

    /**
        @notice Triggers the paused state.
        @dev Must be inherited to apply proper access control before calling internal
        implementation on {_pause()}.
     */
    function pause() virtual public {
        _pause();
    }

    /**
        @notice Lifts the paused state.
        @dev Must be inherited to apply proper access control before calling internal
        implementation on {_unpause()}.
     */
    function unpause() virtual public {
        _unpause();
    }

    /// @dev Internal implementation that triggers the paused state.
    function _pause() virtual internal whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /// @dev Internal implementation that lifts the paused state.
    function _unpause() virtual public whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}
