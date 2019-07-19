const {shouldBehaveLikeRole} = require("./Role.behavior");

const OrganizerRoleMock = artifacts.require("OrganizerRoleMock");

// eslint-disable-next-line no-undef
contract("OrganizerRole", function([_, organizer, otherOrganizer, ...otherAccounts]) {
  beforeEach(async function() {
    this.contract = await OrganizerRoleMock.new({from: organizer});
    await this.contract.addOrganizer(otherOrganizer, {from: organizer});
  });

  // Testes scenarios described here.
  shouldBehaveLikeRole(organizer, otherOrganizer, otherAccounts, "Organizer");
});
