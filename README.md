# ConnectionTrap — New Transaction Detector

`ConnectionTrap` watches the ETH balance of a predefined target address. When a native transaction (incoming or outgoing) alters the balance, the trap fires and calls a notifier contract — allowing immediate detection of on-chain activity.

## Objective

The objective of this trap is to detect **any new native transaction** (incoming or outgoing) on a specific wallet address.  
Whenever a transaction occurs that changes the ETH balance of the monitored address, the trap will trigger a response — enabling instant detection of on-chain activity.

## Problem

- Tracking wallet activity in real time can be challenging without constantly polling blockchain nodes or maintaining complex off-chain infrastructure.  
- For critical wallets (e.g., treasuries, cold storage, or monitored accounts), even a single unexpected transaction can be significant.  
- The goal of this trap is to provide a **lightweight, automated, and on-chain method** to detect and respond to such activity without heavy infrastructure or manual checks.

## Trap Logic Summary
Trap Contract: ConnectionTrap.sol
```bash
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

    /// @notice current balance
    function collect() external view override returns (bytes memory) {
        CollectOutput memory o = CollectOutput({
            balance: target.balance
        });
        return abi.encode(o);
    }

    /// @notice new transaction
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
```
## Response Contract: TxNotifier.sol
```bash
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TxNotifier {
    event NewTransactionDetected(string message);

    function notifyTransaction(string calldata message) external {
        emit NewTransactionDetected(message);
    }
}
```

## What It Solves
- Real-time monitoring of treasury wallets.

- Alerting on unexpected activity (e.g., unauthorized withdrawals).

- Integration with off-chain alert systems (Telegram, Slack, dashboards).

## Installation
#### 1. Deploy Contracts (e.g., via Foundry)
```bash
forge create src/ConnectionTrap.sol:ConnectionTrap \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0x...
```
```bash
forge create src/TxNotifier.sol:TxNotifier \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0x...
```
#### 2. Update drosera.toml
```bash
[traps.mytrap]
path = "out/ConnectionTrap.sol/ConnectionTrap.json"
response_contract = "<TxNotifier address>"
response_function = "notifyTransaction(string)"
```
#### 3. Apply changes
```bash
DROSERA_PRIVATE_KEY=0x... drosera apply
```
<img width="707" height="447" alt="image" src="https://github.com/user-attachments/assets/4c8d0db5-f055-4c59-a768-b170b5969d45" />

## Test
- Send ETH to/from target address on Ethereum Hoodi testnet.
- Wait 1-3 blocks.
- Observe logs from Drosera operator:
- get ShouldRespond='true' in logs and Drosera dashboard

## Improvements
- Token-Agnostic Detection – Extend balance checks beyond native ETH to ERC-20, ERC-721, and ERC-1155 tokens. This way, you’ll detect token transfers as well as ETH movements.
- Batch Transaction Tracking – If multiple transactions happen within the same block, aggregate them into a single alert to avoid spam.
- Event Metadata – Include transaction hash, timestamp, and block number in the emitted event for easier off-chain indexing.
- Multi-Address Monitoring – Allow monitoring multiple wallet addresses in a single trap to reduce deployment overhead.
- Suspicious Pattern Alerts – Implement optional logic to detect unusual frequency or size of transactions over a period.

## Date
Created: August 14, 2025
## Author *Vegas721*
Discord: *bourne321*
