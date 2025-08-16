// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TxNotifier {
    event NewTransactionDetected(
        address indexed target,
        uint256 newBalance,
        uint256 oldBalance,
        string direction
    );


    /// @param target
    /// @param newBalance
    /// @param oldBalance
    /// @param direction ("Incoming"/"Outgoing")
    function notifyTransaction(
        address target,
        uint256 newBalance,
        uint256 oldBalance,
        string calldata direction
    ) external {
        emit NewTransactionDetected(target, newBalance, oldBalance, direction);
    }
}
