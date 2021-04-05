const {expectRevert} = require("@openzeppelin/test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

// const ContestTeamMock = artifacts.require("ContestTeamMock");
const ContestTeamFactory = artifacts.require("ContestTeamFactory");

/**
 * @describe These tests validate the functionality of {ContestTeamFactory.sol}
 * @dev Tests coverage:
 * - Access controls and other integrity checks (modifiers): checks if contract reverts
 * when appropriate, as well as allows usage when sender has the right permission.
 * - Core functionality: checks the intended contract's core functionality, making sure it
 * performs what is expected (PS: due to the complexity in some scenarios, where the next test
 * depends on previous steps, and to keep each test independent, some tests duplicate codes to
 * execute the required steps needed to validate the expected functionality).
 * - Events: checks if contracts triggers the expected events
 */
contract("ContestTeamFactory", function([_, team1]) {
  const name = web3.utils.asciiToHex("name", 32);
  const emptyName = web3.utils.asciiToHex("", 32);

  beforeEach(async function() {
    this.contract = await ContestTeamFactory.new(name, {from: team1});
  });

  describe("ContestTeamFactory core functionality", function() {
    context("deploys new ContestTeam contract", async function() {
      let deployedId = -1;
      let deployedName;
      let deployedAddress;
      let deployedOwner;
      let triggeredEvent;

      beforeEach(async function() {
        const {logs} = await this.contract.createTeamContract(name, {from: team1});
        const {args: Result, event} = logs[0];
        triggeredEvent = event;
        deployedId = new BigNumber(Result.id);
        deployedName = web3.utils.hexToAscii(Result.name).replace(/\0/g, "");
        deployedAddress = Result.contractAddress;
        deployedOwner = Result.creator;
      });

      it("deploys contract and triggers event", async function() {
        expect(deployedId.toNumber()).to.equal(0);
        expect(deployedName).to.equal("name");
        expect(deployedOwner).to.equal(team1);
        expect(triggeredEvent).to.equal("NewContestTeamContract");
      });

      it("gets deployed ContestTeam contract by id", async function() {
        const address = await this.contract.getTeamContractById(deployedId, {from: team1});
        expect(address).to.equal(deployedAddress);
      });

      it("gets deployed ContestTeam contract by name", async function() {
        const address = await this.contract.getTeamContractByName(name, {from: team1});
        expect(address).to.equal(deployedAddress);
      });
    });

    context("security  checks", function() {
      it("reverts when ContestTeam name is empty", async function() {
        await expectRevert(this.contract.createTeamContract(emptyName, {from: team1}), "Team name cannot be empty");
      });

      it("reverts if not a unique name", async function() {
        await this.contract.createTeamContract(name, {from: team1});
        await expectRevert(this.contract.createTeamContract(name, {from: team1}), "Team name already in use");
      });
    });
  });
});
