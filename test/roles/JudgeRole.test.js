const {shouldBehaveLikeRole} = require("./Role.behavior");

const JudgeRoleMock = artifacts.require("JudgeRoleMock");

contract("JudgeRole", function([_, judge, otherJudge, ...otherAccounts]) {
  beforeEach(async function() {
    this.contract = await JudgeRoleMock.new({from: judge});
    await this.contract.addJudge(otherJudge, {from: judge});
  });

  // Testes scenarios described here.
  shouldBehaveLikeRole(judge, otherJudge, otherAccounts, "Judge");
});
