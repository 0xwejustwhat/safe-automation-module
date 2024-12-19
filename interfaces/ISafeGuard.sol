// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./IAutomationModule.sol";

interface ISafeGuard {
    function validatePreExecution(IAutomationModule.TransactionPlan calldata plan) external view returns (bool);
    function reportPostExecution(bytes32 transactionId) external;
} 