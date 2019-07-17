/* global artifacts */
// const AttendeeRole = artifacts.require("./roles/AttendeeRole");
// const JudgeRole = artifacts.require("./roles/JudgeRole");
// const OrganizerRole = artifacts.require("./roles/OrganizerRole");
const OrganizerRoleMock = artifacts.require("OrganizerRoleMock");

module.exports = function(deployer) {
  deployer.then(async () => {
    // await deployer.deploy(AttendeeRole);
    // await deployer.deploy(JudgeRole);
    // await deployer.deploy(OrganizerRole);
    await deployer.deploy(OrganizerRoleMock);
  });
};
