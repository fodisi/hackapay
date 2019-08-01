/* global artifacts */
const SafeMathLib = artifacts.require("SafeMath");
const HackathonFactory = artifacts.require("HackathonFactory");
const ContestTeamFactory = artifacts.require("ContestTeamFactory");

module.exports = function(deployer) {
  deployer.then(async () => {
    // await deployer.deploy(AttendeeRole);
    // await deployer.deploy(JudgeRole);
    // await deployer.deploy(OrganizerRole);
    await deployer.deploy(SafeMathLib);
    await deployer.link(SafeMathLib, HackathonFactory);
    await deployer.link(SafeMathLib, ContestTeamFactory);
    await deployer.deploy(HackathonFactory);
    await deployer.deploy(ContestTeamFactory);
  });
};
