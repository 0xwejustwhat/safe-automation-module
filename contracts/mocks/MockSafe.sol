// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

contract MockSafe {
    event ExecutionFromModule(address indexed module, bool success);

    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        uint8 operation
    ) external returns (bool success) {
        // Mock successful execution
        emit ExecutionFromModule(msg.sender, true);
        return true;
    }
} 