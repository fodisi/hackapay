require("openzeppelin-test-helpers/configure")({web3});
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
      await expectRevert(ContestMock.new(id.toString(), name, description, {from: organizer1}), "Name cannot be empty");
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
});
