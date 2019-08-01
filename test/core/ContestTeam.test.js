const {expectRevert, expectEvent} = require("openzeppelin-test-helpers");
const {expect} = require("chai");
const BigNumber = require("bignumber.js");

const ContestTeamMock = artifacts.require("ContestTeamMock");

/**
 * @describe These tests validate the functionality of {ContestTeam.sol} by using
 * a Mock inherited contract ({ContestTeamMock})
 * @dev Tests coverage:
 * - Access controls and other integrity checks (modifiers): checks if contract reverts
 * when appropriate, as well as allows usage when sender has the right permission.
 * - Core functionality: checks the intended contract's core functionality, making sure it
 * performs what is expected (PS: due to the complexity in some scenarios, where the next test
 * depends on previous steps, and to keep each test independent, some tests duplicate codes to
 * execute the required steps needed to validate the expected functionality).
 * - Events: checks if contracts triggers the expected events
 */
contract("ContestTeam", function([_, member1, member2, nonMember, ...otherAccounts]) {
  beforeEach(async function() {
    this.contract = await ContestTeamMock.new({from: member1});
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

  describe("validates contract's accounting and permissions", function() {
    context("deposits", function() {
      it("allows deposits and emits Deposit event", async function() {
        const expectBalance = new BigNumber(1);
        const {logs} = await this.contract.deposit({from: nonMember, value: expectBalance});
        const resultBalance = new BigNumber(await web3.eth.getBalance(this.contract.address));
        expect(resultBalance.toNumber()).to.equal(expectBalance.toNumber());
        expectEvent.inLogs(logs, `Deposit`, {from: nonMember});
      });

      it("reverts on deposits with 1 value", async function() {
        await expectRevert(this.contract.deposit({from: nonMember, value: 0}), "msg.value must be greather than 0");
      });
    });

    context("splitPrize prechecks", function() {
      it("does not allow calls from not members", async function() {
        await expectRevert(
          this.contract.splitPrize({from: nonMember}),
          "AttendeeRole: caller does not have Attendee Role."
        );
      });

      it("does not allow calls if contract balance is 0", async function() {
        await expectRevert(this.contract.splitPrize({from: member1}), "ContestantTeam balance is 0");
      });

      it("does not allow calls if member prize is 0", async function() {
        await this.contract.deposit({from: nonMember, value: 1});
        await expectRevert(this.contract.splitPrize({from: member1}), "Member prize is 0");
      });
    });

    context("splitPrize validation", function() {
      const depositAmount = web3.utils.toWei("2", "ether");
      const expectedTotalBalance = new BigNumber(depositAmount);

      beforeEach(async function() {
        await this.contract.deposit({from: nonMember, value: depositAmount});
      });

      it("allows call from team members and emits event", async function() {
        const {logs} = await this.contract.splitPrize({from: member1});
        expectEvent.inLogs(logs, `PrizeSplit`, {sender: member1, totalPrize: depositAmount});
      });

      it("splits funds correctly", async function() {
        const expectedMemberPrize = new BigNumber(web3.utils.toWei("1", "ether"));
        await this.contract.splitPrize({from: member1});
        const member1Balance = new BigNumber(await this.contract.balanceOf({from: member1}));
        const member2Balance = new BigNumber(await this.contract.balanceOf({from: member2}));
        expect(member1Balance.toNumber()).to.equal(expectedMemberPrize.toNumber());
        expect(member2Balance.toNumber()).to.equal(expectedMemberPrize.toNumber());
      });

      it("reserves contract's balance", async function() {
        const expectedReservedBalance = new BigNumber(expectedTotalBalance.toNumber());
        const expectedAvailableBalance = new BigNumber(0);
        await this.contract.splitPrize({from: member1});
        const resultTotalBalance = new BigNumber(await web3.eth.getBalance(this.contract.address));
        const resultReservedBalance = new BigNumber(await this.contract.getReservedBalance({from: member1}));
        const resultAvailableBalance = new BigNumber(await this.contract.getAvailableBalance({from: member2}));
        expect(resultTotalBalance.toNumber()).to.equal(expectedTotalBalance.toNumber());
        expect(resultReservedBalance.toNumber()).to.equal(expectedReservedBalance.toNumber());
        expect(resultAvailableBalance.toNumber()).to.equal(expectedAvailableBalance.toNumber());
      });
    });

    context("withdrawal", function() {
      const depositAmount = web3.utils.toWei("2", "ether");
      const expectedTotalBalance = new BigNumber(depositAmount);

      beforeEach(async function() {
        await this.contract.deposit({from: nonMember, value: depositAmount});
        await this.contract.splitPrize({from: member1});
      });

      it("reverts on not enough balance", async function() {
        await expectRevert(this.contract.withdraw("1", {from: nonMember}), "Not enough balance");
      });

      it("allows withdraw and emits event", async function() {
        const withdrawAmount = new BigNumber(web3.utils.toWei("0.5", "ether"));
        const {logs} = await this.contract.withdraw(withdrawAmount.toString(), {from: member1});
        expectEvent.inLogs(logs, `Withdraw`, {to: member1, amount: withdrawAmount.toString()});
      });

      it("allows partial withdraws and updates contract's ledger properly", async function() {
        const memberBalanceBefore = new BigNumber(web3.utils.toWei("1", "ether"));
        const withdrawAmount = new BigNumber(web3.utils.toWei("0.5", "ether"));
        const expectedMemberBalanceAfter = memberBalanceBefore.dividedBy(2);
        const expectedReservedBalance = expectedTotalBalance.minus(withdrawAmount);
        await this.contract.withdraw(withdrawAmount.toString(), {from: member1});
        const resultMember1Balance = new BigNumber(await this.contract.balanceOf({from: member1}));
        const resultMember2Balance = new BigNumber(await this.contract.balanceOf({from: member2}));
        const resultReservedBalance = new BigNumber(await this.contract.getReservedBalance({from: nonMember}));
        const resultAvailableBalance = new BigNumber(await this.contract.getAvailableBalance({from: nonMember}));
        expect(resultMember1Balance.toNumber()).to.equal(expectedMemberBalanceAfter.toNumber());
        expect(resultMember2Balance.toNumber()).to.equal(memberBalanceBefore.toNumber());
        expect(resultReservedBalance.toNumber()).to.equal(expectedReservedBalance.toNumber());
        expect(resultAvailableBalance.toNumber()).to.equal(new BigNumber(0).toNumber());
      });
    });
  });
});
