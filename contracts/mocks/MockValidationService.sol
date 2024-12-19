// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../interfaces/IStrategyValidationService.sol";

contract MockValidationService is IStrategyValidationService {
    bool private tokenValid;

    function setTokenValid(bool _isValid) external {
        tokenValid = _isValid;
    }

    function verifyToken(IAutomationModule.AuthToken calldata) external view override returns (bool) {
        return tokenValid;
    }
} 