const {expectRevert, expectEvent} = require("openzeppelin-test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

const HackathonMock = artifacts.require("HackathonMock");
const ContestTeamMock = artifacts.require("ContestTeamMock");

contract("HackathonMock", function([
  _,
  organizer1,
  judge1,
  judge2,
  team1,
  team2,
  team3,
  team4,
  team5,
  nonParticipant,
  ...otherAccounts
]) {
  const name = web3.utils.asciiToHex("name", 32);
  const description = web3.utils.asciiToHex("description", 32);
  const totalPrize = web3.utils.toWei("10", "wei");

  beforeEach(async function() {
    this.contract = await HackathonMock.new("0", name, description, {from: organizer1});
  });

  describe("Prize allocation", function() {
    context("security and access control checks", function() {
      it("reverts when contract has not enough funds", async function() {
        await expectRevert(
          this.contract.allocatePrize("3", "2", "1", {from: organizer1}),
          "Not enough funds available in hackathon contract"
        );
      });

      it("reverts if prize allocation is already done", async function() {
        await this.contract.dummyAllocatePrizesMock({from: organizer1});
        await expectRevert(this.contract.allocatePrize("3", "2", "1", {from: organizer1}), "Prizes already allocated");
      });
    });

    context("expected prize allocation behavior", function() {
      beforeEach(async function() {
        await this.contract.deposit({from: nonParticipant, value: totalPrize});
      });

      it("allocates prizes when total prize equals balance", async function() {
        await this.contract.allocatePrize("5", "3", "2", {from: organizer1});
        expect(await this.contract.getPrizeAllocationStatus()).to.equal(true);
      });

      it("allocates prizes when total prize smaller than balance", async function() {
        await this.contract.allocatePrize("4", "3", "2", {from: organizer1});
        expect(await this.contract.getPrizeAllocationStatus()).to.equal(true);
      });

      it("emits PrizeAllocation event", async function() {
        const {logs} = await this.contract.allocatePrize("5", "3", "2", {from: organizer1});
        expectEvent.inLogs(logs, `PrizeAllocation`, {
          firstPlacePrize: "5",
          secondPlacePrize: "3",
          thirdPlacePrize: "2",
          organizer: organizer1,
        });
      });
    });
  });

  describe("withdrawPrize", function() {
    context("checks", function() {
      it("reverts when rank is not published", async function() {
        await expectRevert(this.contract.withdrawPrize(team1, {from: nonParticipant}), "Rank not published yet");
      });

      it("reverts when prize is not allocated", async function() {
        await this.contract.dummyPublishRankMock({from: organizer1});
        await expectRevert(this.contract.withdrawPrize(team1, {from: nonParticipant}), "Prizes not allocated yet");
      });

      it("reverts when account address is equal to contract's address", async function() {
        await this.contract.dummyPublishRankMock({from: organizer1});
        await this.contract.dummyAllocatePrizesMock({from: organizer1});
        await expectRevert(
          this.contract.withdrawPrize(this.contract.address, {from: nonParticipant}),
          "Address cannot be equal to contract (this) address"
        );
      });

      it("reverts when account address is not a winner", async function() {
        // There's not winners yet, so any "valid" address (not 0, no contrat's) should fail.
        await this.contract.dummyPublishRankMock({from: organizer1});
        await this.contract.dummyAllocatePrizesMock({from: organizer1});
        await expectRevert(
          this.contract.withdrawPrize(team1, {from: nonParticipant}),
          "Account address is not a winner"
        );
      });
    });

    context("validates withdrawPrize behavior", function() {
      const first = {address: team1, grade: 20};
      const second = {address: team2, grade: 16};
      const third = {address: team3, grade: 14};
      const teamIds = ["0", "1", "2", "3", "4"];
      const teamGrades = [10, 8, 7, 6, 5];
      const sumOfPrizes = web3.utils.toWei("1", "ether");
      const prize1st = web3.utils.toWei("0.5", "ether");
      const prize2nd = web3.utils.toWei("0.3", "ether");
      const prize3rd = web3.utils.toWei("0.2", "ether");
      let team1Contract;
      let team2Contract;
      let team3Contract;

      beforeEach(async function() {
        // Deploys ContestTeam contracts
        team1Contract = await ContestTeamMock.new({from: team1});
        team2Contract = await ContestTeamMock.new({from: team2});
        team3Contract = await ContestTeamMock.new({from: team3});
        first.address = team1Contract.address;
        second.address = team2Contract.address;
        third.address = team3Contract.address;
        // Registers 2 judges.
        await this.contract.addJudge(judge1, {from: organizer1});
        await this.contract.addJudge(judge2, {from: organizer1});
        // Registers 5 teams
        await this.contract.openRegistration({from: organizer1});
        await this.contract.registerTeam(name, first.address, description, {from: team1});
        await this.contract.registerTeam(name, second.address, description, {from: team2});
        await this.contract.registerTeam(name, third.address, description, {from: team3});
        await this.contract.registerTeam(name, team4, description, {from: team4});
        await this.contract.registerTeam(name, team5, description, {from: team5});
        await this.contract.closeRegistration({from: organizer1});
        // Judges (2) submit evaluation for 5 teams and closes evaluation
        await this.contract.openEvaluation({from: organizer1});
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
        // Funds contract and Allocates prizes
        await this.contract.deposit({from: nonParticipant, value: sumOfPrizes});
        await this.contract.allocatePrize(prize1st, prize2nd, prize3rd, {from: organizer1});
      });

      it("allows all winners to withdraw", async function() {
        // START WITHDRAW PROCESS
        const initialBalance1st = new BigNumber(await team1Contract.getBalance());
        const initialBalance2nd = new BigNumber(await team2Contract.getBalance());
        const initialBalance3rd = new BigNumber(await team3Contract.getBalance());
        await this.contract.withdrawPrize(first.address, {from: nonParticipant});
        await this.contract.withdrawPrize(second.address, {from: nonParticipant});
        await this.contract.withdrawPrize(third.address, {from: nonParticipant});
        const finalBalance1st = new BigNumber(await team1Contract.getBalance());
        const finalBalance2nd = new BigNumber(await team2Contract.getBalance());
        const finalBalance3rd = new BigNumber(await team3Contract.getBalance());
        expect(finalBalance1st.minus(initialBalance1st).toNumber()).to.equal(new BigNumber(prize1st).toNumber());
        expect(finalBalance2nd.minus(initialBalance2nd).toNumber()).to.equal(new BigNumber(prize2nd).toNumber());
        expect(finalBalance3rd.minus(initialBalance3rd).toNumber()).to.equal(new BigNumber(prize3rd).toNumber());
      });

      it("reverts if winners try to withdraw more than once", async function() {
        await this.contract.withdrawPrize(first.address, {from: nonParticipant});
        await expectRevert(
          this.contract.withdrawPrize(first.address, {from: nonParticipant}),
          "Prize already paid for first place"
        );
        await this.contract.withdrawPrize(second.address, {from: nonParticipant});
        await expectRevert(
          this.contract.withdrawPrize(second.address, {from: nonParticipant}),
          "Prize already paid for second place"
        );
        await this.contract.withdrawPrize(third.address, {from: nonParticipant});
        await expectRevert(
          this.contract.withdrawPrize(third.address, {from: nonParticipant}),
          "Prize already paid for third place"
        );
      });

      it("emits Withdraw event", async function() {
        const result1 = await this.contract.withdrawPrize(first.address, {from: team1});
        const result2 = await this.contract.withdrawPrize(second.address, {from: team2});
        const result3 = await this.contract.withdrawPrize(third.address, {from: team3});
        expectEvent.inLogs(result1.logs, `Withdraw`, {
          to: first.address,
          amount: prize1st,
          rankPosition: "1",
          requester: team1,
        });
        expectEvent.inLogs(result2.logs, `Withdraw`, {
          to: second.address,
          amount: prize2nd,
          rankPosition: "2",
          requester: team2,
        });
        expectEvent.inLogs(result3.logs, `Withdraw`, {
          to: third.address,
          amount: prize3rd,
          rankPosition: "3",
          requester: team3,
        });
      });
    });
  });
});
