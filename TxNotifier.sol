// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title TxNotifier — логгер событий о новых транзакциях
contract TxNotifier {
    /// @notice Событие для фиксации новой транзакции
    event NewTransactionDetected(string message);

    /// @notice Логирование сигнала от ловушки
    /// @param message сообщение от ловушки
    function notifyTransaction(string calldata message) external {
        emit NewTransactionDetected(message);
    }
}
