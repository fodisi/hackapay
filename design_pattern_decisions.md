# Design Pattern Decisions and Best Practices

The contracts developed for this project, implement a series of design patterns and best practices.
These patterns and best practices were chosen to improve the contracts readability (keep them as simple as possible), implement control access, guarantee state integrity, facilitate development and maintainability, as well as implement tested solutions and approaches to improve security.

## Design Patterns

##### Fail Early and Fail Loud ([learn-consensys])

All contracts implement this pattern, by implementing modifiers and/or functin that use `require(expected, "error")` to check for parameters and conditions prior to code execution. No `assert` or `silent fail` is used.

##### Restricting Access ([learn-consensys])

The project implements 04 smart contracts specifically designed to provide role-based access control to inherited smart contracts.
These base contracts ([AttendeeRole.sol], [ContestRoleManager.sol], [JudgeRole.sol], [OrganizerRole.sol]), implement [Open Zeppelin] library [Roles.sol]. After creating these contracts, inherited contracts are able to use modifiers and functions to manage role-based access control to the inherited contract's functionalities. For example, the contract [ContestTeam.sol] inherits from [AttendeeRole.sol] and uses the inherited modifier`onlyAttendee`to restrict access to the function`splitPrize()`.

##### State Machine ([learn-consensys])

The contracts [Hackathon.sol], [ContestTeamRegistry.sol] and [ContestBracketRegistry.sol] implement a state-machine-based approach to control the lifecycle of the hackathon/contest.
Together, they provide methods, i.e., `openRegistration()`, `closeRegistration()`, `openEvaluation()`, `closeEvaluation()`, `publishRank()`, `withdrawPrize()` and others, that modify the contracts' internal state to reflect the current stage the hackathon. These methods also use modifiers that verify if a previous state was met, before continuing the function execution. For exemple, in order to call `publishRank()`, it is required that the evaluation process (grading) is done (modifier `evaluationIsClosed`).

##### Circuit Breaker ([learn-consensys])

The circuit breaker logic is implemented in the contract [Pausable.sol]. This base contract provides functions to trigger and lift a pausable state, as well as modifiers as `whenNotPaused` and `whenPaused` that can be used by inherited contracts to restrict functionality during circuit breaks. The contract [ContestTeam.sol] inherits from [Pausable.sol] and uses the modifier `whenNotPaused` in functions such as `splitPrize()` and `_addAttendee()` for instance, to make sure these functions can be executed only when the contract is not paused.

##### Pull over Push Payments - A.K.A. Withdrawal Pattern ([learn-consensys])

The Withdraw Patterns is implemented by [ContestTeam.sol] and [Hackathon.sol] to split the accounting from the payment logic.
[ContestTeam.sol] implements the function `splitPrize()`, which performs the accounting operations to update team members' balances. At this point, the contract does not send any funds to the team members, but only handles the accounting process by allocating funds to team members. Once balances are updates, team members are able to call the `withdraw` method to transfer their available balance to a Externally Owned Account (EOAs), withdrawing funds from the [ContestTeam.sol] smart contract.
The same pattern is followed by [Hackathon.sol], which implements `allocatePrize` to handle the accounting process and allocates funds to the winner teams. Then, team members can request a withdraw using the method `withdrawPrize`, which will transfer funds to the winner team (a [ContestTeam.sol] contract).

## Best Practices

In addition to the design patterns mentioned above, the project also implements a few best practices and patterns:

##### Modularization (consensys-best-practices)

Contracts were kept small and simple, as much as possible. Functionalities were split between base contracts, that were then inherited by more specialized contracts, to bundle a set of functionalities and allow modularity and better testing.
Bellow, we can see the inheritance tree of the [ContesTeam.sol] contract:

    Roles.sol ----- AttendeeRole.sol    |
                    Payable.sol         |------------ ContestTeam.sol
                    Pausable.sol        |

[Roles.sol] library and AttendeeRole.sol provide access control functionality for team members;
[Payable.sol] provides the functionality for the contract to receive funds (a payable deposit function);
[Pausable.sol] provides a 'Circuit Breaker' functionality, allowing the contract to stop execution of critical functionality if required.
By inheriting from those contracts, [ContestTeam.sol] only needs to implement the logic related to managing active team members, split prizes among members and allow them to withdraw funds from the contract.

##### Contract Factory ([medium-patterns])

The Contract Factory pattern is implemented by the contracts [HackathonFactory.sol] and [ContestTeamFactory.sol].
These contracts are responsible for dynamically deploying new instances of [Hackathon.sol] and [ContestTeam.sol] contracts, respectively.

##### Mapping Iterator ([medium-patterns])

Many times we'd need to iterate a mapping, but since mappings in Solidity cannot be iterated and they only store values, the Mapping Iterator pattern turns out to be extremely useful. In additional to the mapping, the contracts in this project use an array of the same type of the key used for the mapping.
As an example, the [ContestTeam.sol] implements this patterns to keep track of team member addresses and active team members.

```
address[] internal teamMembers; // List of members
mapping(address => bool) internal activeTeamMembers; // Controls active members
```


##### Unit Test ([truffle-tests])

To minimize the risk of bugs in the developed contracts, and to minimize the chance of changes in the code base to introduce unexpected bugs and/or breaking functionalities, a set of unit tests (and some more complex integration tests) were created.
The project currently has 130 unit tests. By using a test coverage tool as [solidity-coverage], we can see that the project currently covers approx. 96% of the smart contract's lines of code (but there's still room for improvement).
Below are the test coverage results for the developed smart contracts.

**Smart Contracts Test Coverage Results**

| File                              | % Stmts    | % Branch   | % Funcs    | % Lines    | Uncovered Lines  |
| --------------------------------- | ---------- | ---------- | ---------- | ---------- | ---------------- |
| core/                             | 95.1       | 86         | 92.65      | 95.37      |                  |
| ContestBracketRegistry.sol        | 95.31      | 96.88      | 95         | 95.52      | 245,246,247      |
| ContestTeam.sol                   | 95.12      | 66.67      | 80         | 95.12      | 128,136          |
| ContestTeamRegistry.sol           | 92.98      | 83.33      | 93.33      | 93.75      | 226,271,272,292  |
| Hackathon.sol                     | 97.62      | 88.46      | 100        | 97.73      | 137              |
| IContest.sol                      | 100        | 100        | 100        | 100        |                  |
| factory/                          | 91.67      | 83.33      | 83.33      | 92.86      |                  |
| ContestTeamFactory.sol            | 91.67      | 83.33      | 83.33      | 92.86      | 53               |
| HackathonFactory.sol              | 91.67      | 83.33      | 83.33      | 92.86      | 60               |
| lifecycle/                        | 100        | 100        | 100        | 100        |                  |
| Pausable.sol                      | 100        | 100        | 100        | 100        |                  |
| mocks/                            | 100        | 100        | 93.75      | 100        |                  |
| AttendeeRoleMock.sol              | 100        | 100        | 100        | 100        |                  |
| ContestBracketRegistryMock.sol    | 100        | 100        | 100        | 100        |                  |
| ContestRoleManagerMock.sol        | 100        | 100        | 100        | 100        |                  |
| ContestTeamMock.sol               | 100        | 100        | 100        | 100        |                  |
| ContestTeamRegistryMock.sol       | 100        | 100        | 100        | 100        |                  |
| HackathonMock.sol                 | 100        | 100        | 100        | 100        |                  |
| JudgeRoleMock.sol                 | 100        | 100        | 100        | 100        |                  |
| OrganizerRoleMock.sol             | 100        | 100        | 100        | 100        |                  |
| PausableMock.sol                  | 100        | 100        | 60         | 100        |                  |
| payment/                          | 100        | 100        | 100        | 100        |                  |
| IPayable.sol                      | 100        | 100        | 100        | 100        |                  |
| Payable.sol                       | 100        | 100        | 100        | 100        |                  |
| roles/                            | 100        | 80         | 100        | 100        |                  |
| AttendeeRole.sol                  | 100        | 75         | 100        | 100        |                  |
| ContestRoleManager.sol            | 100        | 100        | 100        | 100        |                  |
| JudgeRole.sol                     | 100        | 100        | 100        | 100        |                  |
| OrganizerRole.sol                 | 100        | 75         | 100        | 100        |                  |
| --------------------------------- | ---------- | ---------- | ---------- | ---------- | ---------------- |
| All files                         | 96.03      | 85.94      | 93.92      | 96.28      |                  |

[solidity-coverage]: https://www.npmjs.com/package/solidity-coverage
[open zeppelin]: https://github.com/OpenZeppelin/openzeppelin-contracts
[learn-consensys]: https://learn.consensys.net/unit/view/id:1971
[medium-patterns]: https://medium.com/@i6mi6/solidty-smart-contracts-design-patterns-ecfa3b1e9784
[consensys-best-practices]: https://consensys.github.io/smart-contract-best-practices/general_philosophy/
[truffle-tests]: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
