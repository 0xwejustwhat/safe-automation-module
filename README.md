# Safe Automation Module

A module for the Safe smart contract wallet that enables secure, automated transaction execution through validated transaction plans submitted by whitelisted strategists.

## Overview

The Safe Automation Module serves as a secure bridge between strategists and Safe wallets, enabling automated transaction execution while maintaining strict security controls. It implements a lightweight validation mechanism that ensures only authorized strategists can submit pre-validated transaction plans.

### Key Features

- **Strategist Whitelisting**: Only approved strategists can submit transaction plans
- **Validation Token System**: Lightweight, efficient validation using cryptographic tokens
- **Safe Integration**: Seamless integration with Safe's module system
- **Gas Optimization**: Minimized on-chain computation for validation checks
- **Flexible Transaction Plans**: Support for multi-step transaction execution

## Architecture

The module consists of three main components:

1. **AutomationModule Contract**: Core module that integrates with Safe
   - Manages strategist whitelist
   - Validates transaction submissions
   - Forwards validated transactions to Safe

2. **ValidationHelper Contract**: Handles token generation and verification
   - Generates unique validation tokens for transaction plans
   - Verifies tokens using efficient cryptographic methods
   - Maintains minimal state for gas optimization

3. **Off-chain Validation Service** (to be implemented):
   - Validates transaction plans before submission
   - Generates validation tokens using the same logic as the on-chain helper

### Security Model

The module implements multiple layers of security:

- Whitelisting of strategists
- Validation token verification
- Token expiration checks
- Prevention of token reuse
- Safe's built-in module security

## Installation

```bash
npm install
```

## Development

```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy
npx hardhat run scripts/deploy.ts
```

## Testing

The test suite covers:
- Validation token generation and verification
- Strategist whitelisting functionality
- Transaction plan submission and execution
- Error cases and security checks
- Integration with Safe

## Usage

1. Deploy the ValidationHelper contract
2. Deploy the AutomationModule contract with:
   - Safe address
   - ValidationHelper address
3. Enable the module in your Safe
4. Whitelist strategists
5. Strategists can then submit validated transaction plans

### Submitting Transaction Plans

```typescript
// Generate validation token
const token = await validationHelper.generateValidationToken(
    transactionPlan,
    strategistAddress,
    validUntil
);

// Submit transaction plan
await automationModule.submitTransactionPlan(
    transactionPlan,
    token
);
```

## Design Decisions

1. **Lightweight Validation**: 
   - Uses cryptographic hashing instead of signatures
   - Minimizes on-chain computation
   - Reduces gas costs

2. **Separation of Concerns**:
   - Validation logic separated from core module
   - Clear boundaries between components
   - Easier to upgrade and maintain

3. **Safe Integration**:
   - Uses Safe's module system
   - Leverages existing security features
   - Maintains compatibility with Safe ecosystem

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

LGPL-3.0-only

## Security

This module is pending audit and should not be used in production without proper security review.

For security concerns, please email [security contact].