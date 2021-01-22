// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

/// @notice Defines the structure that a payable contract must implement to receive funds.
interface IPayable {
    /// @notice Allows the contract to receive funds.
    function deposit() external payable;
}
