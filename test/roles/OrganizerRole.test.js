// The MIT License(MIT)

// Copyright(c) 2016 - 2019 zOS Global Limited

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files(the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
//   distribute, sublicense, and / or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be included
//   in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Based on OpenZeppelin source code: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/test/access/roles/MinterRole.test.js

require("openzeppelin-test-helpers/configure")({web3});
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
