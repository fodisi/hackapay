// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "./IPayable.sol";

/// @notice A contract that can receive funds/deposits.
contract Payable is IPayable {
    /// @notice Event emitted when the contract receives a deposit.
    event Deposit(address indexed from, uint256 amount, uint256 indexed datetime);

    /// @notice Allows the contract to receive funds.
    function deposit() external payable override {
        require(msg.value > 0, "msg.value must be greather than 0");
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }
}
