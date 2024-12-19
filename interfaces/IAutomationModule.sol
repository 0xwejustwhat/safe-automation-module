// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

interface IAutomationModule {
    struct ActionStep {
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
        address issuedBy;
        uint256 validUntil;
    }
    
    struct WhitelistChanges {
        address[] strategists;
        address[] assets;
        address[] protocols;
        address[] pools;
        bool[] statuses;
    }
    
    function submitTransactionPlan(
        TransactionPlan calldata plan,
        AuthToken calldata authToken
    ) external returns (bytes32);
    
    function validateAuthToken(AuthToken calldata token) external view returns (bool);
} 