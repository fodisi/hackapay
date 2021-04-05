const {expectRevert} = require("@openzeppelin/test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

const HackathonFactory = artifacts.require("HackathonFactory");

/**
 * @describe These tests validate the functionality of {HackathonFactory.sol}
 * @dev Tests coverage:
 * - Access controls and other integrity checks (modifiers): checks if contract reverts
 * when appropriate, as well as allows usage when sender has the right permission.
 * - Core functionality: checks the intended contract's core functionality, making sure it
 * performs what is expected (PS: due to the complexity in some scenarios, where the next test
 * depends on previous steps, and to keep each test independent, some tests duplicate codes to
 * execute the required steps needed to validate the expected functionality).
 * - Events: checks if contracts triggers the expected events
 */
contract("HackathonFactory", function([_, organizer1]) {
  const name = web3.utils.asciiToHex("name", 32);
  const emptyName = web3.utils.asciiToHex("", 32);
  const description = web3.utils.asciiToHex("description", 32);

  beforeEach(async function() {
    this.contract = await HackathonFactory.new("0", name, description, {from: organizer1});
  });

  describe("HackathonFactory core functionality", function() {
    context("deploys new Hackathon contract", async function() {
      let deployedId = -1;
      let deployedName;
      let deployedDescription;
      let deployedAddress;
      let deployedOwner;
      let triggeredEvent;

      beforeEach(async function() {
        const {logs} = await this.contract.createHackathonContract(name, description, {from: organizer1});
        const {args: Result, event} = logs[0];
        triggeredEvent = event;
        deployedId = new BigNumber(Result.id);
        deployedName = web3.utils.hexToAscii(Result.name).replace(/\0/g, "");
        deployedDescription = web3.utils.hexToAscii(Result.description).replace(/\0/g, "");
        deployedAddress = Result.contractAddress;
        deployedOwner = Result.creator;
      });

      it("deploys contract and triggers event", async function() {
        expect(deployedId.toNumber()).to.equal(0);
        expect(deployedName).to.equal("name");
        expect(deployedDescription).to.equal("description");
        expect(deployedOwner).to.equal(organizer1);
        expect(triggeredEvent).to.equal("NewHackathonContract");
      });

      it("gets deployed Hackathon contract by id", async function() {
        const address = await this.contract.getHackathonContractById(deployedId, {from: organizer1});
        expect(address).to.equal(deployedAddress);
      });

      it("gets deployed Hackathon contract by name", async function() {
        const address = await this.contract.getHackathonContractByName(name, {from: organizer1});
        expect(address).to.equal(deployedAddress);
      });
    });

    context("security  checks", function() {
      it("reverts when hackathon name is empty", async function() {
        await expectRevert(
          this.contract.createHackathonContract(emptyName, description, {from: organizer1}),
          "Hackathon name cannot be empty"
        );
      });

      it("reverts if not a unique name", async function() {
        await this.contract.createHackathonContract(name, description, {from: organizer1});
        await expectRevert(
          this.contract.createHackathonContract(name, description, {from: organizer1}),
          "Hackathon name already in use"
        );
      });
    });
  });
});
