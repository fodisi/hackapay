const {expectRevert, expectEvent} = require("@openzeppelin/test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

const ContestBracketRegistryMock = artifacts.require("ContestBracketRegistryMock");

/**
 * @describe These tests validate the functionality of {ContestBracketRegistry.sol} by using
 * a Mock inherited contract ({ContestBracketRegistryMock})
 * @dev Tests coverage:
 * - Access controls and other integrity checks (modifiers): checks if contract reverts
 * when appropriate, as well as allows usage when sender has the right permission.
 * - Core functionality: checks the intended contract's core functionality, making sure it
 * performs what is expected (PS: due to the complexity in some scenarios, where the next test
 * depends on previous steps, and to keep each test independent, some tests duplicate codes to
 * execute the required steps needed to validate the expected functionality).
 * - Events: checks if contracts triggers the expected events
 */
contract("ContestBracketRegistry", function([
  _,
  organizer1,
  judge1,
  judge2,
  team1,
  team2,
  team3,
  team4,
  team5,
  team6,
  ...otherAccounts
]) {
  const name = web3.utils.asciiToHex("name", 32);
  const proposalData = web3.utils.asciiToHex("proposal", 32);

  beforeEach(async function() {
    this.contract = await ContestBracketRegistryMock.new({from: organizer1});
  });

  describe("Team registry basic functionality", function() {
    context("Creates contract with initial states", function() {
      it("creates contract and checks initial status", async function() {
        const expected = false;
        const evaluationStatus = await this.contract.getEvaluationStatus();
        expect(evaluationStatus).to.equal(expected);
      });

      it("Opens/Closes evaluation, updates state and emits events", async function() {
        const expectedOpenStatus = true;
        const expectedClosedStatus = false;
        // Opens and checks evaluation
        let event = await this.contract.openEvaluation({from: organizer1});
        let evaluationStatus = await this.contract.getEvaluationStatus();
        expectEvent.inLogs(event.logs, `EvaluationStatusUpdated`, {enabled: expectedOpenStatus});
        expect(evaluationStatus).to.equal(expectedOpenStatus);
        // Closes and checks evaluation
        event = await this.contract.closeEvaluation({from: organizer1});
        evaluationStatus = await this.contract.getEvaluationStatus();
        expectEvent.inLogs(event.logs, `EvaluationStatusUpdated`, {enabled: expectedClosedStatus});
        expect(evaluationStatus).to.equal(expectedClosedStatus);
      });
    });

    context("checks modifiers and reverts", function() {
      it("closeEvaluation reverts if evaluation is already closed", async function() {
        await expectRevert(this.contract.closeEvaluation({from: organizer1}), "Evaluation is closed");
      });

      it("openEvaluation reverts if evaluation is already open", async function() {
        await this.contract.openEvaluation({from: organizer1});
        await expectRevert(this.contract.openEvaluation({from: organizer1}), "Evaluation is open");
      });

      it("openEvaluation reverts if not organizer", async function() {
        await expectRevert(
          this.contract.openEvaluation({from: judge1}),
          "OrganizerRole: caller does not have Organizer Role."
        );
      });

      it("closeEvaluation reverts if not organizer", async function() {
        await this.contract.openEvaluation({from: organizer1});
        await expectRevert(
          this.contract.closeEvaluation({from: judge1}),
          "OrganizerRole: caller does not have Organizer Role."
        );
      });

      it("openSubmission reverts if not organizer", async function() {
        await expectRevert(
          this.contract.openSubmission({from: judge1}),
          "OrganizerRole: caller does not have Organizer Role."
        );
      });

      it("closeSubmission reverts if not organizer", async function() {
        await this.contract.openSubmission({from: organizer1});
        await expectRevert(
          this.contract.closeSubmission({from: judge1}),
          "OrganizerRole: caller does not have Organizer Role."
        );
      });

      it("openEvaluation reverts if not organizer", async function() {
        await expectRevert(
          this.contract.openEvaluation({from: judge1}),
          "OrganizerRole: caller does not have Organizer Role."
        );
      });

      it("closeEvaluation reverts if not organizer", async function() {
        await this.contract.openEvaluation({from: organizer1});
        await expectRevert(
          this.contract.closeEvaluation({from: judge1}),
          "OrganizerRole: caller does not have Organizer Role."
        );
      });
    });
  });

  describe("submit evaluation", function() {
    beforeEach(async function() {
      await this.contract.openRegistration({from: organizer1});
      await this.contract.openEvaluation({from: organizer1});
      await this.contract.addJudge(judge1, {from: organizer1});
    });

    context("checks", function() {
      it("reverts if submission is not open", async function() {
        await this.contract.closeEvaluation({from: organizer1});
        await expectRevert(this.contract.submitEvaluation([], [], {from: judge1}), "Evaluation is closed");
      });

      it("reverts if not judge", async function() {
        await expectRevert(
          this.contract.submitEvaluation([], [], {from: organizer1}),
          "JudgeRole: caller does not have Judge Role."
        );
      });

      it("reverts if length of id and grade arrays differ", async function() {
        await expectRevert(
          this.contract.submitEvaluation([0, 1], [9], {from: judge1}),
          "Length of teams and teamGrades arrays must be equal"
        );
      });

      it("reverts if length of id and grade arrays differ from approvedTeamCount", async function() {
        await expectRevert(
          this.contract.submitEvaluation([0], [9], {from: judge1}),
          "teamsIds and grades do not match the counting of approved teams"
        );
      });

      it("reverts if there's no approved team", async function() {
        await expectRevert(this.contract.submitEvaluation([], [], {from: judge1}), "No approved teams to evaluate");
      });

      it("reverts if invalid team id", async function() {
        // Team id would be 0.
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await expectRevert(this.contract.submitEvaluation([1], [1], {from: judge1}), "Invalid team id");
      });

      it("reverts if team is not approved", async function() {
        // Team id would be 0.
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        // Adds second team, so it won't failt due to array length not equal to approved teams.
        await this.contract.registerTeam(name, team2, proposalData, {from: team2});
        await this.contract.reproveTeam("0", {from: organizer1});
        await expectRevert(this.contract.submitEvaluation([0], [1], {from: judge1}), "Team is not approved");
      });

      it("reverts if grade is invalid", async function() {
        // Team id would be 0.
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await expectRevert(this.contract.submitEvaluation([0], [11], {from: judge1}), "Invalid grade");
      });

      it("it allows min and max grade values", async function() {
        // Team id would be 0.
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await this.contract.registerTeam(name, team2, proposalData, {from: team2});
        await this.contract.submitEvaluation([0, 1], [0, 10], {from: judge1});
        // Should execute without errors.
        expect(true);
      });

      it("it reverts if judge already voted", async function() {
        // Team id would be 0.
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await this.contract.registerTeam(name, team2, proposalData, {from: team2});
        await this.contract.submitEvaluation([0, 1], [0, 10], {from: judge1});
        await expectRevert(
          this.contract.submitEvaluation([0, 1], [0, 10], {from: judge1}),
          "Judge already submitted evaluation"
        );
      });
    });

    context("Grading", function() {
      it("computes grades correctly and saves it into team's struct", async function() {
        const gradeTeam1 = new BigNumber(5);
        const gradeTeam2 = new BigNumber(10);
        const teamIds = ["0", "1"];
        const teamGrades = [5, 10];
        await this.contract.addJudge(judge2, {from: organizer1});
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await this.contract.registerTeam(name, team2, proposalData, {from: team2});
        await this.contract.submitEvaluation(teamIds, teamGrades, {from: judge1});
        await this.contract.submitEvaluation(teamIds, teamGrades, {from: judge2});
        const resultTeam1 = await this.contract.getTeam(teamIds[0], {from: organizer1});
        const resultTeam2 = await this.contract.getTeam(teamIds[1], {from: organizer1});
        const teamAddress1 = resultTeam1[1]; // address team 1
        const teamAddress2 = resultTeam2[1]; // address team 2
        const resultGrade1 = new BigNumber(resultTeam1[4]); // Team2 grade
        const resultGrade2 = new BigNumber(resultTeam2[4]); // Team2 grade
        expect(teamAddress1).to.equal(team1);
        expect(teamAddress2).to.equal(team2);
        expect(resultGrade1.toNumber()).to.equal(gradeTeam1.multipliedBy(2).toNumber());
        expect(resultGrade2.toNumber()).to.equal(gradeTeam2.multipliedBy(2).toNumber());
      });
    });

    context("Ranking", function() {
      it("reverts if registrationIsOpen, submissionIsOpen or evaluationIsOpen", async function() {
        await this.contract.closeEvaluation({from: organizer1});
        await expectRevert(this.contract.publishRank({from: organizer1}), "Registration is open");
        await this.contract.closeRegistration({from: organizer1});
        await this.contract.openSubmission({from: organizer1});
        await expectRevert(this.contract.publishRank({from: organizer1}), "Submission is open");
        await this.contract.closeSubmission({from: organizer1});
        await this.contract.openEvaluation({from: organizer1});
        await expectRevert(this.contract.publishRank({from: organizer1}), "Evaluation is open");
      });

      it("reverts if tries to publishRank with no teams registered", async function() {
        await this.contract.closeRegistration({from: organizer1});
        await this.contract.closeEvaluation({from: organizer1});
        await expectRevert(this.contract.publishRank({from: organizer1}), "No teams registered");
      });

      it("reverts if rank already published", async function() {
        await this.contract.closeEvaluation({from: organizer1});
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await this.contract.closeRegistration({from: organizer1});
        await this.contract.openEvaluation({from: organizer1});
        await this.contract.submitEvaluation(["0"], [10], {from: judge1});
        await this.contract.closeEvaluation({from: organizer1});
        await this.contract.publishRank({from: organizer1});
        await expectRevert(this.contract.publishRank({from: organizer1}), "Rank already published");
      });

      it("calculates and publishes ranking correctly", async function() {
        const first = {address: team4, grade: 20};
        const second = {address: team6, grade: 18};
        const third = {address: team5, grade: 16};
        const teamIds = ["0", "1", "2", "3", "4", "5"];
        const teamGrades = [7, 7, 7, 10, 8, 9];
        // Registers 2nd judge. Total of 2 judges.
        await this.contract.addJudge(judge2, {from: organizer1});
        // Registers 6 teams
        await this.contract.registerTeam(name, team1, proposalData, {from: team1});
        await this.contract.registerTeam(name, team2, proposalData, {from: team2});
        await this.contract.registerTeam(name, team3, proposalData, {from: team3});
        await this.contract.registerTeam(name, team4, proposalData, {from: team4});
        await this.contract.registerTeam(name, team5, proposalData, {from: team5});
        await this.contract.registerTeam(name, team6, proposalData, {from: team6});
        await this.contract.closeRegistration({from: organizer1});
        // Judges (2) submit evaluation for 6 teams and closes evaluation
        await this.contract.submitEvaluation(teamIds, teamGrades, {from: judge1});
        await this.contract.submitEvaluation(teamIds, teamGrades, {from: judge2});
        await this.contract.closeEvaluation({from: organizer1});
        // Review ranking and get winners's data
        await this.contract.publishRank({from: organizer1});
        const winners = await this.contract.getWinnersIds({from: organizer1});
        const resultFirst = await this.contract.getTeam(winners[0], {from: organizer1});
        const resultSecond = await this.contract.getTeam(winners[1], {from: organizer1});
        const resultThird = await this.contract.getTeam(winners[2], {from: organizer1});
        // Checks winners by comparing their addresses (result[1]) and grades (result[4]).
        expect(resultFirst[1]).to.equal(first.address);
        expect(new BigNumber(resultFirst[4]).toNumber()).to.equal(first.grade);
        expect(resultSecond[1]).to.equal(second.address);
        expect(new BigNumber(resultSecond[4]).toNumber()).to.equal(second.grade);
        expect(resultThird[1]).to.equal(third.address);
        expect(new BigNumber(resultThird[4]).toNumber()).to.equal(third.grade);
      });
    });
  });
});
