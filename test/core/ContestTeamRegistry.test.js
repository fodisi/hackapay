const {expectRevert, expectEvent} = require("openzeppelin-test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

const ContestTeamRegistryMock = artifacts.require("ContestTeamRegistryMock");

contract("ContestTeamRegistry", function([_, organizer1, team1, team2, team3, ...otherAccounts]) {
  const name = web3.utils.asciiToHex("name", 32);
  const proposalData = web3.utils.asciiToHex("proposal", 32);

  beforeEach(async function() {
    this.contract = await ContestTeamRegistryMock.new({from: organizer1});
  });

  describe("Team registry basic functionality", function() {
    context("Creates contract with initial states", function() {
      it("creates contract and checks initial status", async function() {
        const expected = false;
        const registrationStatus = await this.contract.getRegistrationStatus();
        const submissionStatus = await this.contract.getSubmissionStatus();
        expect(registrationStatus).to.equal(expected);
        expect(submissionStatus).to.equal(expected);
      });

      it("Opens/Closes for registration and submission updadtes state and emits events", async function() {
        const expectedOpenStatus = true;
        const expectedClosedStatus = false;
        // Opens and checks registration
        let event = await this.contract.openRegistration();
        let registrationStatus = await this.contract.getRegistrationStatus();
        expectEvent.inLogs(event.logs, `RegistrationStatusUpdated`, {enabled: expectedOpenStatus});
        expect(registrationStatus).to.equal(expectedOpenStatus);
        // Opens and checks submission
        event = await this.contract.openSubmission();
        let submissionStatus = await this.contract.getSubmissionStatus();
        expectEvent.inLogs(event.logs, `SubmissionStatusUpdated`, {enabled: expectedOpenStatus});
        expect(submissionStatus).to.equal(expectedOpenStatus);
        // Closes and checks registration
        event = await this.contract.closeRegistration();
        registrationStatus = await this.contract.getRegistrationStatus();
        expectEvent.inLogs(event.logs, `RegistrationStatusUpdated`, {enabled: expectedClosedStatus});
        expect(registrationStatus).to.equal(expectedClosedStatus);
        // Closes and checks submission
        event = await this.contract.closeSubmission();
        submissionStatus = await this.contract.getSubmissionStatus();
        expectEvent.inLogs(event.logs, `SubmissionStatusUpdated`, {enabled: expectedClosedStatus});
        expect(submissionStatus).to.equal(expectedClosedStatus);
      });
    });

    context("checks modifiers and reverts", function() {
      it("registerTeam reverts if registration is closed", async function() {
        await expectRevert(
          this.contract.registerTeam(name, team1, proposalData, {from: team1}),
          "Registration is closed"
        );
      });

      it("registerTeam reverts if name is empty", async function() {
        const emptyName = web3.utils.asciiToHex("", 32);
        await this.contract.openRegistration();
        await expectRevert(
          this.contract.registerTeam(emptyName, team1, proposalData, {from: team1}),
          "Team name cannot be empty"
        );
      });

      it("registerTeam reverts if teamAddress already registered", async function() {
        await this.contract.openRegistration();
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await expectRevert(
          this.contract.registerTeam(name, team1, proposalData, {from: team1}),
          "Team already registered"
        );
      });

      it("updateProposal reverts if teamId is invalid", async function() {
        await expectRevert(this.contract.updateProposalData("0", proposalData, {from: team1}), "Invalid team id");
      });

      it("updateProposal reverts if teamId is not approved", async function() {
        await this.contract.openRegistration();
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await this.contract.reproveTeam("0", {from: team1});
        await expectRevert(this.contract.updateProposalData("0", proposalData, {from: team1}), "Team is not approved");
      });

      it("updateProposal reverts if submission is closed", async function() {
        await this.contract.openRegistration();
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await expectRevert(this.contract.updateProposalData("0", proposalData, {from: team1}), "Submission is closed");
      });
    });

    context("Team registry management", function() {
      it("Add teams, emits TeamRegistered event and increases internal counter", async function() {
        const expectedFirstTeamId = 0;
        const expectedSecondTeamId = 1;
        const expectedTeamCount = 2;
        await this.contract.openRegistration();
        const result1 = await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        expectEvent.inLogs(result1.logs, `TeamRegistered`, {
          teamId: expectedFirstTeamId.toString(),
          teamAddress: team1,
        });
        const result2 = await this.contract.registerTeam(name, team2, proposalData, {from: team2});
        expectEvent.inLogs(result2.logs, `TeamRegistered`, {
          teamId: expectedSecondTeamId.toString(),
          teamAddress: team2,
        });
        const resultTeamCount = new BigNumber(await this.contract.getApprovedTeamsCount.call());
        expect(resultTeamCount.toNumber()).to.equal(expectedTeamCount);
      });

      it("gets team by id", async function() {
        await this.contract.openRegistration();
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        const result = await this.contract.getTeam("0", {from: organizer1});
        const {0: resultName, 1: resultAddress, 2: resultProposal} = result;
        expect(web3.utils.hexToAscii(resultName).replace(/\0/g, "")).to.equal("name");
        expect(resultAddress).to.equal(team1);
        expect(web3.utils.hexToAscii(resultProposal).replace(/\0/g, "")).to.equal("proposal");
      });

      it("updates proposal data", async function() {
        const updatedProposalData = web3.utils.asciiToHex("updatedProposal", 32);
        await this.contract.openRegistration();
        await this.contract.openSubmission();
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await this.contract.updateProposalData("0", updatedProposalData, {from: team1});
        const result = await this.contract.getTeam("0", {from: organizer1});
        const {2: resultProposal} = result;
        expect(web3.utils.hexToAscii(resultProposal).replace(/\0/g, "")).to.equal("updatedProposal");
      });

      it("reproves team and emits event", async function() {
        await this.contract.openRegistration();
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        const {logs} = await this.contract.reproveTeam("0", {from: organizer1});
        const result = await this.contract.getTeam("0", {from: team1});
        const {3: resultApproved} = result;
        expectEvent.inLogs(logs, `TeamStatusUpdated`, {teamId: "0", teamAddress: team1, approved: false});
        expect(resultApproved).be.false;
      });

      it("re-approves team and emits event", async function() {
        await this.contract.openRegistration();
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        const reproved = await this.contract.reproveTeam("0", {from: organizer1});
        expectEvent.inLogs(reproved.logs, `TeamStatusUpdated`, {teamId: "0", teamAddress: team1, approved: false});
        // Re-approves the team.
        const approved = await this.contract.approveTeam("0", {from: organizer1});
        const result = await this.contract.getTeam("0", {from: team1});
        const {3: resultApproved} = result;
        expectEvent.inLogs(approved.logs, `TeamStatusUpdated`, {teamId: "0", teamAddress: team1, approved: true});
        expect(resultApproved).be.true;
      });
    });
  });
});
