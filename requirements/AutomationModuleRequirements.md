**Specification: Automation Module (Safe Module)**

**Purpose**

The Automation Module is a Gnosis Safe module responsible for securely executing validated transaction plans submitted by strategists. It serves as the intermediary for interaction with Safe core components and other on-chain modules, ensuring compliance with validation and whitelist policies.

**Responsibilities**

1. **Strategist Whitelisting Enforcement**
    - Ensures that only whitelisted strategists can submit transaction plans for execution.
2. **Authentication Token Validation**
    - Verifies tokens issued by the Strategy Validation Service to confirm that transactions have undergone off-chain validation.
3. **Transaction Submission to Safe Core**
    - Forwards validated transactions to the Safe core for execution.
4. **Intermediary Role**
    - Acts as an intermediary between the Safe Modifier and Safe Guard, facilitating necessary interactions and updates.

**Key Features**

1. **Transaction Submission**
    - Accepts transaction plans from authorized strategists.
    - Verifies the validity of associated authentication tokens.
2. **Forwarding Transactions to Safe Core**
    - Sends validated transactions to the Safe core for execution.
    - Ensures Safe core invokes the Safe Guard for pre- and post-execution checks:
        - Pre-execution: Validates assets, protocols, and pools.
        - Post-execution: Reports the updated Safe state back to the strategist.
3. **Integration with Safe Modifier and Safe Guard**
    - Collaborates with the Safe Modifier and Safe Guard to enforce compliance with whitelist policies and validation rules.
4. **Event Emission**
    - Generates logs for transaction submissions, executions, and any errors encountered.

**API Endpoints**

1. **submitTransactionPlan**
    - **Description**: Accepts a transaction plan from a whitelisted strategist.
    - **Inputs**:
        - transactionPlan: Encoded transaction details.
        - authToken: Token issued by the Strategy Validation Service.
    - **Outputs**:
        - Success or rejection message.
        - Transaction ID for tracking.
2. **validateAuthToken**
    - **Description**: Verifies the authenticity of the provided authentication token.
    - **Inputs**:
        - authToken: Token to be validated.
    - **Outputs**:
        - Boolean indicating validity.
3. **forwardTransactionToSafe**
    - **Description**: Forwards a validated transaction to the Safe core for execution.
    - **Inputs**:
        - transactionID: Reference ID for the transaction.
    - **Outputs**:
        - Execution status (success, failure).
        - Event emission.
4. **routeWhitelistUpdates**
    - **Description**: Facilitates updates to the Safe Modifier and Safe Guard.
    - **Inputs**:
        - whitelistChanges: List of updates to strategists, assets, protocols, and pools.
    - **Outputs**:
        - Confirmation of updates.

**Data Structures**

1. **Transaction Plan**
    - Contains:
        - actionSteps\[\]: Array of steps, where each step includes:
            - inputToken: Token used in the step.
            - inputAmount: Amount of the input token.
            - outputToken: Token resulting from the step (if any).
            - outputAmount: Amount of the output token (if any).
    - Represents the transaction plan created by the strategist to be handed over to the validation service.
2. **Validated Transaction**
    - Structure:
        - transactionID: Unique identifier for the transaction.
        - to: Address of the recipient.
        - data: Encoded calldata for the transaction.
        - value: Amount of ETH or tokens being sent (if any).
        - gasLimit: Maximum gas allowed for the transaction.
        - nonce: Unique number to prevent replay attacks.
    - Represents the format of transactions created by the Validator Service and handed over to the strategist along with an authentication token for submission to the Automation Module.
3. **Auth Token**
    - Structure:
        - tokenID: Unique identifier.
        - issuedBy: Validation service.
        - validUntil: Expiry timestamp.

**Integration Points**

1. **Strategy Validation Service**
    - Receives a transaction plan from the strategist.
    - Creates validated transaction data and an authentication token.
    - Returns the validated transaction data and authentication token to the strategist.
2. **Safe Core**
    - Executes forwarded transactions.
    - Invokes the Safe Guard for pre-execution validation and post-execution state reporting.
3. **Safe Modifier**
    - Ensures compliance with whitelist policies before transaction execution.
4. **Safe Guard**
    - Validates assets, protocols, and pools involved in transactions.
    - Reports updated Safe state after transaction execution.
5. **Notification and Logging Module**
    - Sends execution logs and error messages to the notification system.

**User Stories**

1. **Strategist Submits a Transaction Plan**
    - As a strategist, I want to submit a transaction plan along with an authentication token to the Automation Module so that my validated plan can be forwarded to the Safe core for execution.
2. **Safe Core Executes a Validated Transaction**
    - As a Safe owner, I want the Safe core to execute only transactions that have been validated by the Strategy Validation Service and comply with whitelist policies.
3. **Notification on Execution Errors**
    - As a strategist, I want to be notified if a transaction fails during execution so that I can investigate and revise my strategy accordingly.
4. **Whitelist Updates**
    - As a Safe owner, I want updates to whitelist policies to be routed through the Automation Module so that compliance with Safe Guard and Safe Modifier is ensured.
5. **Safe State Reporting**
    - As a strategist, I want to receive updated Safe state information after transaction execution so that I can adjust my future strategies.

**Stakeholder Responsibilities**

1. **Strategists**:
    - Submit transaction plans with proper validation.
    - Monitor execution results and update strategies as needed.
2. **Safe Owners**:
    - Review and approve whitelist updates for assets, protocols, and pools.
    - Monitor transaction logs and execution results to ensure compliance.
3. **Developers**:
    - Implement and maintain the Automation Module and its integrations.
    - Ensure robust error handling, logging, and reporting.

**Versioning and Deployment Strategy**

1. **Versioning**:
    - Use semantic versioning (e.g., vX.Y.Z).
    - Increment major version for breaking changes, minor version for backward-compatible features, and patch version for bug fixes.
2. **Deployment Strategy**:
    - Automate deployments via CI/CD pipelines.
    - Maintain separate environments for development, staging, and production.
    - Perform automated tests at each deployment stage to ensure stability.

**Risk Management**

1. **Risk Identification**:
    - Unauthorized transactions: Mitigated by authentication and whitelist enforcement.
    - Execution failures: Handled with robust error reporting and fallback mechanisms.
    - Security vulnerabilities: Addressed through regular audits and adherence to best practices.
2. **Mitigation Strategies**:
    - Implement detailed logging for traceability.
    - Schedule periodic code reviews and penetration testing.
    - Maintain a disaster recovery plan for critical failures.

**Documentation**

1. **API Documentation**:
    - Generate API documentation using tools like Swagger or OpenAPI.
    - Ensure that the API documentation is up-to-date with all endpoints and data structures.
2. **Technical Documentation**:
    - Maintain a detailed README file in the project repository.
    - Include explanations of the module’s architecture, key functions, and data structures.
    - Provide step-by-step setup and deployment instructions.
    - Specify that the module should be developed in a **new subproject under the project root**, separate from safe-modules and safe-smart-account.
3. **User Documentation**:
    - Create a user guide for strategists and Safe owners.
    - Include instructions on submitting transaction plans, reviewing execution logs, and managing whitelist updates.
4. **Change Logs**:
    - Maintain a changelog documenting all updates, fixes, and feature additions in each version.
5. **Knowledge Base**:
    - Establish a developer wiki for FAQs, troubleshooting, and best practices.
6. **Code Comments**:
    - Emphasize the importance of clear and comprehensive code comments.
    - Ensure all critical sections of code are explained to improve readability and maintainability.
7. **Technical Documentation**:
    - Maintain a detailed README file in the project repository.
    - Include explanations of the module’s architecture, key functions, and data structures.
    - Provide step-by-step setup and deployment instructions.
    - Specify that the module should be developed in a **new subproject under the project root**, separate from safe-modules and safe-smart-account.
8. **User Documentation**:
    - Create a user guide for strategists and Safe owners.
    - Include instructions on submitting transaction plans, reviewing execution logs, and managing whitelist updates.
9. **Change Logs**:
    - Maintain a changelog documenting all updates, fixes, and feature additions in each version.
10. **Knowledge Base**:
    - Establish a developer wiki for FAQs, troubleshooting, and best practices.

**Cursor Rules**

rules:

\- under_no_circumstances:

description: Do not modify Safe core contracts.

\- interact_via_endpoints:

description: All interactions with Safe must use the provided endpoints and APIs.

\- consistent_tech_stack:

description: Follow the tech stack used in Safe-smart-account and Safe-modules.

\- windows_compatibility:

description: Ensure all code is compatible with Windows and PowerShell terminal.

\- test_separation:

description: Keep unit tests and integration tests separate, and mock dependencies in a separate suite if needed.

\- context_limitation:

description: Only consider files in the current module directory and include external references only when necessary.

\- solidity_best_practices:

description: Adhere to Solidity best practices, including:

\- Avoid reentrancy vulnerabilities.

\- Use \`require\` statements for input validation.

\- Optimize gas usage.

\- Favor readability and maintainability in contract code.

\- api_documentation:

description: Generate API documentation using tools like Swagger or OpenAPI and ensure it is kept up-to-date.

\- code_comments:

description: Write clear and comprehensive comments for all critical code sections to improve readability and maintainability.

description: Adhere to Solidity best practices, including:

\- Avoid reentrancy vulnerabilities.

\- Use \`require\` statements for input validation.

\- Optimize gas usage.

\- Favor readability and maintainability in contract code.

\- module_development:

description: Develop the Automation Module in a new subproject under the project root, separate from \`safe-modules\` and \`safe-smart-account\`.