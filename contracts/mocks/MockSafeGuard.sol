// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../interfaces/ISafeGuard.sol";

contract MockSafeGuard is ISafeGuard {
    bool private preExecutionValid = true;
    mapping(bytes32 => bool) public executionReported;

    function setPreExecutionValid(bool _isValid) external {
        preExecutionValid = _isValid;
    }

    function validatePreExecution(IAutomationModule.TransactionPlan calldata) 
        external 
        view 
        override 
        returns (bool) 
    {
        return preExecutionValid;
    }

    function reportPostExecution(bytes32 transactionId) external override {
        executionReported[transactionId] = true;
    }

    function wasExecutionReported(bytes32 transactionId) external view returns (bool) {
        return executionReported[transactionId];
    }
} 