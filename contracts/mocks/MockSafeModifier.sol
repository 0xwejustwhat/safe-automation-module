// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

contract MockSafeModifier {
    bool public whitelistUpdateReceived;
    
    function receiveWhitelistUpdate() external {
        whitelistUpdateReceived = true;
    }
} 