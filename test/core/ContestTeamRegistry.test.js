const {expectRevert, expectEvent} = require("openzeppelin-test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

const ContestTeamRegistryMock = artifacts.require("ContestTeamRegistryMock");

contract("ContestTeamRegistry", function([_, organizer1, organizer2, judge1, judge2, ...otherAccounts]) {
  beforeEach(async function() {
    this.contract = await ContestTeamRegistryMock.new({from: organizer1});
  });

  describe("Contract creation and registry status", function() {
    it("creates contract and checks initial status", async function() {
      const expected = false;
      const registrationStatus = await this.contract.getRegistrationStatus();
      const submissionStatus = await this.contract.getSubmissionStatus();
      expect(registrationStatus).to.equal(expected);
      expect(submissionStatus).to.equal(expected);
    });

    // FIX: test is failing.
    it("Opens/Closes for registration and submission", async function() {
      const expectedOpenStatus = true;
      const expectedClosedStatus = true;
      // Opens for registration and submission
      await this.contract.openRegistration();
      await this.contract.openSubmission();
      let registrationStatus = await this.contract.getRegistrationStatus();
      let submissionStatus = await this.contract.getSubmissionStatus();
      expect(registrationStatus).to.equal(expectedOpenStatus);
      expect(submissionStatus).to.equal(expectedOpenStatus);
      // Closes for registration and submission
      await this.contract.closeRegistration();
      // await this.contract.closeSubmission();
      registrationStatus = await this.contract.getRegistrationStatus();
      // submissionStatus = await this.contract.getSubmissionStatus();
      expect(registrationStatus).to.equal(expectedClosedStatus);
      // expect(submissionStatus).to.equal(expectedClosedStatus);
    });
  });
});
