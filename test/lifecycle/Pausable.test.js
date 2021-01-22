const {expectRevert, expectEvent} = require("@openzeppelin/test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

const PausableMock = artifacts.require("PausableMock");

/**
 * @describe These tests validate the functionality of {Pausable.sol} by using
 * a Mock inherited contract ({PausableMock})
 * @dev Tests coverage:
 * - Access controls and other integrity checks (modifiers): checks if contract reverts
 * when appropriate, as well as allows usage when sender has the right permission.
 * - Core functionality: checks the intended contract's core functionality, making sure it
 * performs what is expected (PS: due to the complexity in some scenarios, where the next test
 * depends on previous steps, and to keep each test independent, some tests duplicate codes to
 * execute the required steps needed to validate the expected functionality).
 * - Events: checks if contracts triggers the expected events
 */
contract("Pausable", function([_, organizer1, nonOrganizer, ...otherAccounts]) {
  describe("access control", function() {
    beforeEach(async function() {
      this.contract = await PausableMock.new({from: organizer1});
    });

    it("reverts is calling onlyWorksWhenPaused when NOT PAUSED", async function() {
      await expectRevert(this.contract.onlyWorksWhenPaused({from: organizer1}), "Contract is not paused");
    });

    it("reverts if calling onlyWorksWhenNotPaused when PAUSED", async function() {
      await this.contract.pause({from: organizer1});
      await expectRevert(this.contract.onlyWorksWhenNotPaused({from: organizer1}), "Contract is paused");
    });

    it("reverts if caller is not organizer", async function() {
      await expectRevert(
        this.contract.pause({from: nonOrganizer}),
        "OrganizerRole: caller does not have Organizer Role."
      );
    });
  });

  describe("emits events and updates state", function() {
    beforeEach(async function() {
      this.contract = await PausableMock.new({from: organizer1});
    });

    it("emits Paused and triggers paused state", async function() {
      const {logs} = await this.contract.pause({from: organizer1});
      const isPaused = await this.contract.isPaused();
      expectEvent.inLogs(logs, `Paused`, {account: organizer1});
      expect(isPaused).to.equal(true);
    });

    it("emits Unpaused and lifts paused state", async function() {
      await this.contract.pause({from: organizer1});
      const {logs} = await this.contract.unpause({from: organizer1});
      const isPaused = await this.contract.isPaused();
      expectEvent.inLogs(logs, `Unpaused`, {account: organizer1});
      expect(isPaused).to.equal(false);
    });
  });
  // NOT TESTING ACCESS CONTROL FUNCTIONALITY HERE SINCE THIS MUST IMPLEMENTED BY ANOTHER CONTRACT.
});
