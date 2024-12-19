// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./IAutomationModule.sol";

interface IStrategyValidationService {
    function verifyToken(IAutomationModule.AuthToken calldata token) external view returns (bool);
} 