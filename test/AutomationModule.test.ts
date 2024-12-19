import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

describe("AutomationModule", function () {
  let automationModule: Contract;
  let mockValidationService: Contract;
  let mockSafeGuard: Contract;
  let mockSafeModifier: Contract;
  let owner: HardhatEthersSigner;
  let strategist: HardhatEthersSigner;
  let nonStrategist: HardhatEthersSigner;

  beforeEach(async function () {
    // Get signers
    [owner, strategist, nonStrategist] = await ethers.getSigners();
    console.log('Addresses:', {
        owner: owner.address,
        strategist: strategist.address,
        nonStrategist: nonStrategist.address
    });

    // Deploy mock contracts
    const MockValidationService = await ethers.getContractFactory("MockValidationService");
    mockValidationService = await MockValidationService.deploy();
    await mockValidationService.waitForDeployment();

    const MockSafeGuard = await ethers.getContractFactory("MockSafeGuard");
    mockSafeGuard = await MockSafeGuard.deploy();
    await mockSafeGuard.waitForDeployment();

    const MockSafeModifier = await ethers.getContractFactory("MockSafeModifier");
    mockSafeModifier = await MockSafeModifier.deploy();
    await mockSafeModifier.waitForDeployment();

    // Deploy AutomationModule
    const AutomationModule = await ethers.getContractFactory("AutomationModule");
    automationModule = await AutomationModule.deploy(
      await mockValidationService.getAddress(),
      await mockSafeGuard.getAddress(),
      await mockSafeModifier.getAddress()
    );
    await automationModule.waitForDeployment();

    // Whitelist the strategist
    await automationModule.updateWhitelist(strategist.address, true);
  });

  describe("Constructor", function () {
    it("Should set the correct initial values", async function () {
      expect(await automationModule.validationService()).to.equal(await mockValidationService.getAddress());
      expect(await automationModule.safeGuard()).to.equal(await mockSafeGuard.getAddress());
      expect(await automationModule.safeModifier()).to.equal(await mockSafeModifier.getAddress());
    });

    it("Should revert with zero addresses", async function () {
      const AutomationModule = await ethers.getContractFactory("AutomationModule");
      await expect(
        AutomationModule.deploy(
          ethers.ZeroAddress,
          await mockSafeGuard.getAddress(),
          await mockSafeModifier.getAddress()
        )
      ).to.be.revertedWith("Invalid validation service address");
    });
  });

  describe("Whitelisting", function () {
    it("Should allow owner to whitelist strategist", async function () {
      await expect(automationModule.updateWhitelist(nonStrategist.address, true))
        .to.emit(automationModule, "WhitelistUpdated")
        .withArgs(nonStrategist.address, true);
      
      expect(await automationModule.whitelistedStrategists(nonStrategist.address)).to.be.true;
    });

    it("Should not allow non-owner to whitelist strategist", async function () {
      await expect(
        automationModule.connect(nonStrategist).updateWhitelist(nonStrategist.address, true)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe("Transaction Submission", function () {
    let validAuthToken: any;
    let validTransactionPlan: any;

    beforeEach(async function () {
      // Setup valid auth token
      validAuthToken = {
        tokenId: ethers.keccak256(ethers.toUtf8Bytes("validToken")),
        issuedBy: await mockValidationService.getAddress(),
        validUntil: Math.floor(Date.now() / 1000) + 3600 // 1 hour from now
      };

      // Setup valid transaction plan
      validTransactionPlan = {
        actionSteps: [
          {
            inputToken: ethers.Wallet.createRandom().address,
            inputAmount: ethers.parseEther("1"),
            outputToken: ethers.Wallet.createRandom().address,
            outputAmount: ethers.parseEther("2")
          }
        ]
      };

      // Configure mock validation service to approve the token
      await mockValidationService.setTokenValid(true);
    });

    it("Should allow whitelisted strategist to submit transaction plan", async function () {
      await expect(
        automationModule.connect(strategist).submitTransactionPlan(validTransactionPlan, validAuthToken)
      ).to.emit(automationModule, "TransactionSubmitted");
    });

    it("Should reject non-whitelisted strategist", async function () {
      await expect(
        automationModule.connect(nonStrategist).submitTransactionPlan(validTransactionPlan, validAuthToken)
      ).to.be.revertedWith("Caller is not a whitelisted strategist");
    });

    it("Should reject expired auth token", async function () {
      const expiredToken = {
        ...validAuthToken,
        validUntil: Math.floor(Date.now() / 1000) - 3600 // 1 hour ago
      };

      await expect(
        automationModule.connect(strategist).submitTransactionPlan(validTransactionPlan, expiredToken)
      ).to.be.revertedWith("Auth token expired");
    });

    it("Should reject reused auth token", async function () {
      // First submission should succeed
      await automationModule.connect(strategist).submitTransactionPlan(validTransactionPlan, validAuthToken);

      // Second submission with same token should fail
      await expect(
        automationModule.connect(strategist).submitTransactionPlan(validTransactionPlan, validAuthToken)
      ).to.be.revertedWith("Auth token already used");
    });
  });

  describe("Transaction Forwarding", function () {
    it("Should validate pre-execution through Safe Guard", async function () {
      // Test implementation
    });

    it("Should report post-execution state", async function () {
      // Test implementation
    });
  });
}); 