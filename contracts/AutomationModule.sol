// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@gnosis.pm/safe-contracts/contracts/base/ModuleManager.sol";
import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IAutomationModule.sol";
import "../interfaces/IStrategyValidationService.sol";
import "../interfaces/ISafeGuard.sol";

contract AutomationModule is IAutomationModule, Ownable {
    // State variables
    mapping(address => bool) public whitelistedStrategists;
    mapping(bytes32 => bool) public usedAuthTokens;
    IStrategyValidationService public validationService;
    ISafeGuard public safeGuard;
    address public safeModifier;
    
    // Events
    event TransactionSubmitted(bytes32 indexed transactionId, address indexed strategist);
    event TransactionExecuted(bytes32 indexed transactionId, bool success);
    event WhitelistUpdated(address indexed strategist, bool status);
    
    constructor(
        address _validationService,
        address _safeGuard,
        address _safeModifier
    ) {
        require(_validationService != address(0), "Invalid validation service address");
        require(_safeGuard != address(0), "Invalid safe guard address");
        require(_safeModifier != address(0), "Invalid safe modifier address");
        
        validationService = IStrategyValidationService(_validationService);
        safeGuard = ISafeGuard(_safeGuard);
        safeModifier = _safeModifier;
    }
    
    modifier onlyWhitelistedStrategist() {
        require(whitelistedStrategists[msg.sender], "Caller is not a whitelisted strategist");
        _;
    }
    
    function submitTransactionPlan(
        TransactionPlan calldata plan,
        AuthToken calldata authToken
    ) external override onlyWhitelistedStrategist returns (bytes32) {
        // Validate auth token
        require(validateAuthToken(authToken), "Invalid authentication token");
        
        // Generate transaction ID
        bytes32 transactionId = keccak256(abi.encode(plan, block.timestamp, msg.sender));
        
        // Mark auth token as used
        usedAuthTokens[authToken.tokenId] = true;
        
        // Forward transaction to Safe
        bool success = forwardTransactionToSafe(transactionId, plan);
        require(success, "Transaction forwarding failed");
        
        emit TransactionSubmitted(transactionId, msg.sender);
        return transactionId;
    }
    
    function validateAuthToken(AuthToken calldata token) public view returns (bool) {
        require(!usedAuthTokens[token.tokenId], "Auth token already used");
        require(token.validUntil > block.timestamp, "Auth token expired");
        require(token.issuedBy == address(validationService), "Invalid token issuer");
        
        return validationService.verifyToken(token);
    }
    
    function forwardTransactionToSafe(
        bytes32 transactionId,
        TransactionPlan calldata plan
    ) internal returns (bool) {
        // Pre-execution validation through Safe Guard
        require(safeGuard.validatePreExecution(plan), "Pre-execution validation failed");
        
        // Execute transaction steps
        bool success = true;
        for (uint256 i = 0; i < plan.actionSteps.length; i++) {
            // Implementation of transaction execution logic
            // This would interact with the Safe core through the Module Manager
        }
        
        // Post-execution state update
        if (success) {
            safeGuard.reportPostExecution(transactionId);
        }
        
        emit TransactionExecuted(transactionId, success);
        return success;
    }
    
    function updateWhitelist(
        address strategist,
        bool status
    ) external onlyOwner {
        whitelistedStrategists[strategist] = status;
        emit WhitelistUpdated(strategist, status);
    }
    
    function routeWhitelistUpdates(
        WhitelistChanges calldata changes
    ) external onlyOwner {
        // Forward updates to Safe Modifier and Safe Guard
        // Implementation of whitelist update routing
    }
} 