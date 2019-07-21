/* eslint-disable func-names */
const {expectRevert, constants, expectEvent} = require("openzeppelin-test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

const HackathonTeam = artifacts.require("HackathonTeam");

contract("HackathonTeam", function([_, member1, member2, nonMember, ...otherAccounts]) {
  beforeEach(async function() {
    this.contract = await HackathonTeam.new({from: member1});
    await this.contract.addAttendee(member2, {from: member1});
  });

  describe("member management", function() {
    context("controls member count", function() {
      it("has correct initial member count", async function() {
        const expected = 2; // See beforeEach command.
        const result = new BigNumber(await this.contract.getActiveMembersCount());
        expect(result.toNumber()).to.equal(expected);
      });
      it("updates member count on member removal", async function() {
        const expected = 1;
        await this.contract.renounceAttendee({from: member2});
        const result = new BigNumber(await this.contract.getActiveMembersCount());
        expect(result.toNumber()).to.equal(expected);
      });
      it("returns active members", async function() {
        const expected = [member1, member2];
        const result = await this.contract.getActiveMembers();
        expect(result[0]).to.equal(expected[0]);
        expect(result[1]).to.equal(expected[1]);
      });
    });
  });

  describe("contract receives deposits", function() {
    it("it allows deposits and emits Deposit event", async function() {
      const expectBalance = new BigNumber(1);
      const {logs} = await this.contract.deposit({from: nonMember, value: expectBalance});
      const resultBalance = new BigNumber(await web3.eth.getBalance(this.contract.address));
      expect(resultBalance.toNumber()).to.equal(expectBalance.toNumber());
      expectEvent.inLogs(logs, `Deposit`, {from: nonMember});
    });

    it("it reverts on deposits with 1 value", async function() {
      await expectRevert(this.contract.deposit({from: nonMember, value: 0}), "msg.value must be greather than 0");
    });
  });

  describe("split prize", function() {
    context("prechecks", function() {
      it("it does not allow calls from not members", async function() {
        await expectRevert(
          this.contract.splitPrize({from: nonMember}),
          "AttendeeRole: caller does not have Attendee Role."
        );
      });

      it("it does not allow calls if contract balance is 0", async function() {
        await expectRevert(this.contract.splitPrize({from: member1}), "ContestantTeam balance is 0");
      });

      it("it does not allow calls if member prize is 0", async function() {
        await this.contract.deposit({from: nonMember, value: 1});
        await expectRevert(this.contract.splitPrize({from: member1}), "Member prize is 0");
      });
    });

    context("valid prize split", function() {
      it("it allows call from team members and emits event", async function() {
        const totalBalance = web3.utils.toWei("2", "ether");
        await this.contract.deposit({from: nonMember, value: totalBalance});
        const {logs} = await this.contract.splitPrize({from: member1});
        expectEvent.inLogs(logs, `PrizeSplit`, {sender: member1, totalPrize: totalBalance});
      });

      it("it splits funds correctly", async function() {
        const totalBalance = web3.utils.toWei("2", "ether");
        const expectedMemberPrize = new BigNumber(web3.utils.toWei("1", "ether"));
        await this.contract.deposit({from: nonMember, value: totalBalance});
        await this.contract.splitPrize({from: member1});
        const member1Balance = new BigNumber(await this.contract.balanceOf({from: member1}));
        const member2Balance = new BigNumber(await this.contract.balanceOf({from: member2}));
        expect(new BigNumber(member1Balance).toNumber()).to.equal(expectedMemberPrize.toNumber());
        expect(new BigNumber(member2Balance).toNumber()).to.equal(expectedMemberPrize.toNumber());
      });
    });
  });
});
