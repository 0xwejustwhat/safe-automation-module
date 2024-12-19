// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

interface IAutomationModule {
    // Data structures
    struct ActionStep {
        address to;
        uint256 value;
        bytes data;
        address inputToken;
        uint256 inputAmount;
        address outputToken;
        uint256 outputAmount;
    }

    struct TransactionPlan {
        ActionStep[] actionSteps;
    }

    struct AuthToken {
        bytes32 tokenId;
        uint256 validUntil;
        address strategist;
    }

    // Main functions
    function submitTransactionPlan(
        TransactionPlan calldata plan,
        AuthToken calldata authToken
    ) external returns (bytes32);

    // Events
    event TransactionSubmitted(bytes32 indexed transactionId, address indexed strategist);
    event TransactionExecuted(bytes32 indexed transactionId, bool success);
    event WhitelistUpdated(address indexed strategist, bool status);
} 