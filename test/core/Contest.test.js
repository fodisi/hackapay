const {expectRevert, expectEvent} = require("openzeppelin-test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

const ContestMock = artifacts.require("ContestMock");

contract("Contest", function([_, organizer1, organizer2, judge1, judge2, ...otherAccounts]) {
  describe("Contract creation", function() {
    it("reverts on contract creation without name", async function() {
      const id = new BigNumber(1);
      const name = web3.utils.asciiToHex("", 32);
      const description = web3.utils.asciiToHex("", 32);
      await expectRevert(ContestMock.new(id.toString(), name, description, {from: organizer1}), "name cannot be empty");
    });

    it("creates contract and assigns initial values", async function() {
      const id = new BigNumber(1);
      const name = web3.utils.asciiToHex("name", 32);
      const description = web3.utils.asciiToHex("description", 32);
      this.contract = await ContestMock.new(id.toString(), name, description, {from: organizer1});

      const resultId = new BigNumber(await this.contract.id({from: organizer1}));
      const resultName = await this.contract.name.call();
      const resultDescription = await this.contract.description({from: organizer1});
      expect(resultId.toNumber()).to.equal(id.toNumber());
      expect(web3.utils.hexToAscii(resultName).replace(/\0/g, "")).to.equal("name");
      expect(web3.utils.hexToAscii(resultDescription).replace(/\0/g, "")).to.equal("description");
    });
  });

  describe("access control", function() {
    beforeEach(async function() {
      this.contract = await ContestMock.new(
        "1",
        web3.utils.asciiToHex("name", 32),
        web3.utils.asciiToHex("description", 32),
        {from: organizer1}
      );
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
      this.contract = await ContestMock.new(
        "1",
        web3.utils.asciiToHex("name", 32),
        web3.utils.asciiToHex("description", 32),
        {from: organizer1}
      );
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
