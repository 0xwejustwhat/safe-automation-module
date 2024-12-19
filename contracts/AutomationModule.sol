// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@gnosis.pm/safe-contracts/contracts/base/ModuleManager.sol";
import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "../interfaces/IAutomationModule.sol";
import "./ValidationHelper.sol";

/**
 * @title AutomationModule
 * @dev A Safe module for executing validated transaction plans from whitelisted strategists
 */
contract AutomationModule is IAutomationModule, Ownable {
    // State variables
    mapping(address => bool) public whitelistedStrategists;
    mapping(bytes32 => bool) public usedAuthTokens;
    GnosisSafe public safe;
    ValidationHelper public validationHelper;

    /**
     * @dev Constructor sets the validation service address and Safe instance
     * @param _safe Address of the Safe this module is attached to
     * @param _validationHelper Address of the ValidationHelper contract
     */
    constructor(address payable _safe, address _validationHelper) {
        require(_safe != address(0), "Invalid Safe address");
        require(_validationHelper != address(0), "Invalid validation helper address");
        safe = GnosisSafe(_safe);
        validationHelper = ValidationHelper(_validationHelper);
    }

    /**
     * @dev Modifier to restrict access to whitelisted strategists
     */
    modifier onlyWhitelistedStrategist() {
        require(whitelistedStrategists[msg.sender], "Caller is not a whitelisted strategist");
        _;
    }

    /**
     * @dev Submit a transaction plan for execution
     * @param plan The transaction plan to execute
     * @param authToken Authentication token from the validation service
     * @return transactionId Unique identifier for the transaction
     */
    function submitTransactionPlan(
        TransactionPlan calldata plan,
        AuthToken calldata authToken
    ) external override onlyWhitelistedStrategist returns (bytes32) {
        require(!usedAuthTokens[authToken.tokenId], "Auth token already used");
        require(authToken.validUntil > block.timestamp, "Auth token expired");
        require(authToken.strategist == msg.sender, "Invalid strategist");
        
        require(
            validationHelper.verifyValidationToken(authToken, plan, msg.sender),
            "Invalid validation token"
        );

        bytes32 transactionId = keccak256(abi.encode(plan, block.timestamp, msg.sender));
        usedAuthTokens[authToken.tokenId] = true;

        bool success = forwardTransactionToSafe(transactionId, plan);
        require(success, "Transaction forwarding failed");

        emit TransactionSubmitted(transactionId, msg.sender);
        return transactionId;
    }

    /**
     * @dev Forward validated transactions to Safe for execution
     * @param transactionId Unique identifier for the transaction
     * @param plan The transaction plan to execute
     * @return bool indicating if the forwarding was successful
     */
    function forwardTransactionToSafe(
        bytes32 transactionId,
        TransactionPlan calldata plan
    ) internal returns (bool) {
        bool success = true;
        for (uint256 i = 0; i < plan.actionSteps.length; i++) {
            ActionStep memory step = plan.actionSteps[i];
            success = safe.execTransactionFromModule(
                step.to,
                step.value,
                step.data,
                Enum.Operation.Call
            );
            require(success, "Transaction execution failed");
        }

        emit TransactionExecuted(transactionId, success);
        return success;
    }

    /**
     * @dev Update the whitelist status of a strategist
     * @param strategist Address of the strategist
     * @param status New whitelist status
     */
    function updateWhitelist(address strategist, bool status) external onlyOwner {
        require(whitelistedStrategists[strategist] != status, "No change in whitelist status");
        whitelistedStrategists[strategist] = status;
        emit WhitelistUpdated(strategist, status);
    }
} 