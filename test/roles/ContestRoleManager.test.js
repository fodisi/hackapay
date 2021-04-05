const {expectRevert, expectEvent} = require("@openzeppelin/test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

const ContestRoleManagerMock = artifacts.require("ContestRoleManagerMock");

/**
 * @describe These tests validate the functionality of {ContestRoleManager.sol} by using
 * a Mock inherited contract ({ContestRoleManagerMock})
 * @dev Tests coverage:
 * - Access controls and other integrity checks (modifiers): checks if contract reverts
 * when appropriate, as well as allows usage when sender has the right permission.
 * - Core functionality: checks the intended contract's core functionality, making sure it
 * performs what is expected (PS: due to the complexity in some scenarios, where the next test
 * depends on previous steps, and to keep each test independent, some tests duplicate codes to
 * execute the required steps needed to validate the expected functionality).
 * - Events: checks if contracts triggers the expected events
 */
contract("ContestRoleManager", function([_, organizer1, organizer2, judge1, judge2, ...otherAccounts]) {
  describe("access control", function() {
    beforeEach(async function() {
      this.contract = await ContestRoleManagerMock.new({from: organizer1});
    });

    it("does not allow non-organizers to add/remove judges", async function() {
      await expectRevert(
        this.contract.addJudge(judge1, {from: judge1}),
        "OrganizerRole: caller does not have Organizer Role."
      );
      await expectRevert(
        this.contract.removeJudge(judge1, {from: judge1}),
        "OrganizerRole: caller does not have Organizer Role."
      );
    });

    it("allows organizers to add/remove judges", async function() {
      await this.contract.addJudge(judge1, {from: organizer1});
      let isJudge = await this.contract.isJudge(judge1, {from: judge2});
      expect(isJudge).to.equal(true);
      await this.contract.removeJudge(judge1, {from: organizer1});
      isJudge = await this.contract.isJudge(judge1, {from: judge2});
      expect(isJudge).to.equal(false);
    });
  });

  describe("member management", function() {
    beforeEach(async function() {
      this.contract = await ContestRoleManagerMock.new({from: organizer1});
      await this.contract.addOrganizer(organizer2, {from: organizer1});
      await this.contract.addJudge(judge1, {from: organizer1});
      await this.contract.addJudge(judge2, {from: organizer1});
    });

    context("controls member count", function() {
      it("has correct initial organizer count", async function() {
        const expected = 2; // See beforeEach command.
        const organizerCount = new BigNumber(await this.contract.getActiveOrganizersCount());
        expect(organizerCount.toNumber()).to.equal(expected);
      });

      it("has correct initial judge count", async function() {
        const expected = 2; // See beforeEach command.
        const judgeCount = new BigNumber(await this.contract.getActiveJudgesCount());
        expect(judgeCount.toNumber()).to.equal(expected);
      });

      it("updates organizer and judge count on member removal", async function() {
        const expected = 1;
        await this.contract.renounceOrganizer({from: organizer2});
        await this.contract.renounceJudge({from: judge2});
        const organizerCount = new BigNumber(await this.contract.getActiveOrganizersCount());
        const judgeCount = new BigNumber(await this.contract.getActiveJudgesCount());
        expect(organizerCount.toNumber()).to.equal(expected);
        expect(judgeCount.toNumber()).to.equal(expected);
      });
    });
  });
});
