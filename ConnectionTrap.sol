// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract ConnectionTrap is ITrap {
    address public constant target = 0x219Bb3aC626B48DCcc62b2bBdD4eCc66A3561E53;

    struct CollectOutput {
        uint256 balance;
    }

    /// @notice Собираем текущий баланс кошелька
    function collect() external view override returns (bytes memory) {
        CollectOutput memory o = CollectOutput({
            balance: target.balance
        });
        return abi.encode(o);
    }

    /// @notice Если баланс изменился — сработала новая транзакция
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, abi.encode("No history"));
        }

        CollectOutput memory prev = abi.decode(data[0], (CollectOutput));
        CollectOutput memory curr = abi.decode(data[1], (CollectOutput));

        if (curr.balance != prev.balance) {
            return (true, abi.encode("New transaction affecting balance detected"));
        }

        return (false, abi.encode(""));
    }
}
