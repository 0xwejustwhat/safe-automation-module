// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../interfaces/IAutomationModule.sol";

/**
 * @title ValidationHelper
 * @dev Helper contract for generating and validating transaction authentication tokens
 */
contract ValidationHelper {
    /**
     * @dev Generates a validation token for a transaction plan
     * @param plan The transaction plan to validate
     * @param strategist Address of the strategist submitting the plan
     * @param validUntil Timestamp until which the token is valid
     * @return AuthToken The generated validation token
     */
    function generateValidationToken(
        IAutomationModule.TransactionPlan memory plan,
        address strategist,
        uint256 validUntil
    ) public view returns (IAutomationModule.AuthToken memory) {
        bytes32 tokenId = keccak256(
            abi.encode(
                plan.actionSteps,
                strategist,
                validUntil,
                block.timestamp
            )
        );

        return IAutomationModule.AuthToken({
            tokenId: tokenId,
            validUntil: validUntil,
            strategist: strategist
        });
    }

    /**
     * @dev Verifies a validation token against a transaction plan
     * @param token The token to verify
     * @param plan The transaction plan
     * @param strategist Address of the strategist
     * @return bool indicating if the token is valid
     */
    function verifyValidationToken(
        IAutomationModule.AuthToken memory token,
        IAutomationModule.TransactionPlan memory plan,
        address strategist
    ) public pure returns (bool) {
        bytes32 message = keccak256(
            abi.encode(
                plan.actionSteps,
                strategist
            )
        );

        return token.tokenId == message && 
               token.strategist == strategist;
    }
} 