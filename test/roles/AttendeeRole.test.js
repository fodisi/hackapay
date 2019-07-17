const {shouldBehaveLikeRole} = require("./Role.behavior");

const AttendeeRoleMock = artifacts.require("AttendeeRoleMock");

contract("AttendeeRole", function([_, attendee, otherAttendee, ...otherAccounts]) {
  beforeEach(async function() {
    this.contract = await AttendeeRoleMock.new({from: attendee});
    await this.contract.addAttendee(otherAttendee, {from: attendee});
  });

  shouldBehaveLikeRole(attendee, otherAttendee, otherAccounts, "Attendee");
});
