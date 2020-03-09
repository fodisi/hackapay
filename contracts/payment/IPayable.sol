pragma solidity 0.5.16;

/// @notice Defines the structure that a payable contract must implement to receive funds.
interface IPayable {
    /// @notice Allows the contract to receive funds.
    function deposit() external payable;
}
