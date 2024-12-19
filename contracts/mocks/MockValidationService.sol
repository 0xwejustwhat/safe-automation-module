// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../interfaces/IStrategyValidationService.sol";
import "../../interfaces/IAutomationModule.sol";

contract MockValidationService is IStrategyValidationService {
    mapping(bytes32 => bool) public validTokens;

    function verifyToken(IAutomationModule.AuthToken calldata token) external view override returns (bool) {
        return validTokens[token.tokenId];
    }

    // Test helper function
    function setTokenValidity(bytes32 tokenId, bool isValid) external {
        validTokens[tokenId] = isValid;
    }
} 