# Mitigating Know Attacks

The contracts developed for this project, implement a series of design patterns and best practices, such as:

## Attacks and Best Practices Implemented

##### Integer Overflow and Underflow ([known-attacks])

To avoid integer Overflow and Underflow, the SafeMath library, developed by [open zeppelin] was used in all contracts that required using integer types.

##### Reentrancy ([known-attacks])

In general, this attack was mitigated by avoiding external calls to other contracts and/or unknown contracts.
However, in a few methods calling a external contract was required. For example, the [Hackathon.sol] contract calls the `deposit` function of the [ContestTeam.sol] contract, to send funds to the winner team.
The same scenario happens in the method `withdraw` of the [ContestTeam.sol] contract, which transfer funds to a Externally Owned Account (EOA).
In both cases, single function and cross-function reentrancies are mitigated by first finishing all internal work (ie. updating available balances), and only then calling the external function deposit(payable) or transfer function.
In additional to this, these two contracts implement the Withdraw pattern, splitting the accounting and payment functionalities in two different methods.

##### DoS with (Unexpected) revert ([known-attacks])

Again this attack is mitigated in the [Hackathon.sol] and [ContestTeam.sol] contracts by splitting the balance accounting and the transferring of funds in two different methods, using the Withdraw Pattern.
In [ContestTeam.sol], every team member needs to call the `withdraw` method to withdraw funds.
The same strategy is implemented by [Hackathon.sol], in the `withdrawPrize()` method.
If one of the team members or team winners decide to implement a deposit (payable) fallback function that reverts when receives funds, the only account that would have its balance impacted, would be the attacker's account. All the other members would be able to withdraw funds to their team's contract or Externally Owned Accounts.

##### DoS with Block Gas Limit ([known-attacks])

Again, this exploit is avoided by not providing a single method that could be used to transfer funds to all team members / teams winners in [Hackathon.sol] and [ContestTeam.sol]., but by implement the Withdraw Pattern, requiring

##### Forcibly Sending Ether to a Contract ([known-attacks])

The contracts with payable functions [Hackathon.sol] and [ContestTeam.sol], do not have sensitive code that relies on the contract balance.
In [ContestTeam.sol], the logic used to split funds between team members, actually considers the contract's balance and uses and reserved balance to keep track of splits already performed between members. In case the contract receives funds other then via its payable `deposit` function, the additional balance would be available in the next split and could be paid to team members without problems.

## Security Tools

To help identify potential threats to the contracts, the project uses [MythX], which is a powerful security analysis service that finds Solidity vulnerabilities in the Ethereum smart contract code during the development life cycle.

By running the analysis service for the project, we can see that the only warning identified by the tool was the `floating pragma`. This happens because the contracts are defining `pragma solidity ^0.5.0`, instead of `pragma solidity 0.5.0`.
However, this is a low level warning, and at this point of development, does not poses great risks to the project. However, before deploying the project in the mainnet, we should review this `pragma` definition.

**[MythX] Security Analysis Results**

hackapay/contracts/roles/AttendeeRole.sol
26:0 warning A floating pragma is set SWC-103

openzeppelin-solidity/contracts/access/Roles.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/mocks/AttendeeRoleMock.sol
26:0 warning A floating pragma is set SWC-103

hackapay/contracts/core/ContestBracketRegistry.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/core/ContestTeamRegistry.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/roles/ContestRoleManager.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/roles/JudgeRole.sol
26:0 warning A floating pragma is set SWC-103

hackapay/contracts/roles/OrganizerRole.sol
26:0 warning A floating pragma is set SWC-103

openzeppelin-solidity/contracts/math/SafeMath.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/mocks/ContestBracketRegistryMock.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/mocks/ContestRoleManagerMock.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/core/ContestTeam.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/lifecycle/Pausable.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/payment/IPayable.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/payment/Payable.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/factory/ContestTeamFactory.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/mocks/ContestTeamMock.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/mocks/ContestTeamRegistryMock.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/storage/EternalStorage.sol
25:0 warning A floating pragma is set SWC-103

hackapay/contracts/core/Hackathon.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/factory/HackathonFactory.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/mocks/HackathonMock.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/core/IContest.sol
1:0 warning A floating pragma is set SWC-103

hackapay/contracts/mocks/JudgeRoleMock.sol
26:0 warning A floating pragma is set SWC-103

hackapay/contracts/mocks/OrganizerRoleMock.sol
26:0 warning A floating pragma is set SWC-103

hackapay/contracts/mocks/PausableMock.sol
1:0 warning A floating pragma is set SWC-103

✖ 26 problems (0 errors, 26 warnings)

[open zeppelin]: https://github.com/OpenZeppelin/openzeppelin-contracts
[known-attacks]: https://consensys.github.io/smart-contract-best-practices/known-attacks/
[mythx]: https://mythx.io/
