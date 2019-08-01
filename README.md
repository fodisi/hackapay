# Hackapay

HackaPay aims to provide a single platform to manage Hackathons (other contests in the future) facilitating and helping organizers to better manage their Hackathon events, while providing transparency for attendees about prizes, evaluations, final results, improved transparency and credibility, better experience for attendees, and faster payment/distribution of prizes to winners.

### Motivation

**Hackathon Attendees:**
Have you ever attended a Blockchain hackathon where you worked really hard to be a winner and after scoring high, you find out prizes will be paid months later in digital currency; or in Cash; or even worse: in gift cards? Wasn't it supposed to be a _Blockchain Hackathon_?

**Hackathon Organizers:**
Have you ever organized a Hackathon and found yourself struggling to, or trying to figure out how to:

- Keep track of registration (attendees sign up and team formation)
- Control of the submission process
- Provide transparency during the evaluation process
- Publicly publish the results; and/or
- Provide transparency about the prizes you'll to distribute as an incentive
- Distribute the prizes to winner's team members?
- Improve your organizer's image by using the blockchain to distribute prizes?

##### UI:

The UI is still under construction, but you can interact with the `Factories` of the network, which are responsible for deploying and keeping track of the contracts created and deployed by users. There are two Factories in the network:

- Hackathon Factory: Deploys a Hackathon contract to the blockchain. This contract is used for managing ang interacting with the hackathon (registration, proposal submission, evaluation, publishing results, and distributing prizes to winner teams.
- Contest Team Factory: Deploys a ContestTeam contract to the blockchain. This contract is used for managing team members, depositing prizes (from the Hackathon contract) and distribute received prizes among team members.

##### UI Limitations:

The current UI, only interacts with the contract Factories, allowing the creation of new hackathons/teams, and retrieving the addresses of the deployed contracts. The UI still needs to implement the functionalities to interact with the Hackathon and ContestTeam contracts, created and deployed dynamically by the users using the factories.

#### Usefull Information about the project:

- [Deployed contract addresses on testnets (ropsten and lovan)](deployed_addresses.txt)
- [Strategies implemented for avoiding common attacks](avoiding_common_attacks.md)
- [Design Pattern Decisions](design_pattern_decisions.md)

### Contract Diagram

The basic architecture / contract diagram of the project can be seen in the diagram below.

![Alt text](/diagrams/contract-diagram.png?raw=true "Contract Diagram")

## Getting Started

This project was developed with the following environment:

- Ubuntu Ubuntu 18.04.2 LTS
- npm 6.9.0
- Truffle v5.0.28 (core: 5.0.28)
- Solidity v0.5.0 (solc-js)
- Node v10.16.0
- Web3.js v1.0.0-beta.37

  _PS: You should have no problems running on ubuntu 16.04 or Node 8.\*_

#### 1 - Requirements:

###### WebServer and Smart Contracts Development/Deployment

- [node](https://nodejs.org)
- [npm](https://www.npmjs.com/)
- Install [truffle](https://www.trufflesuite.com/truffle): `npm install truffle -g`
- Download and install [Ganache Gui](https://www.trufflesuite.com/ganache) or [ganache-cli](https://www.npmjs.com/package/ganache-cli). Follow instructions provider instructions to install the desired version of Ganache. Make sure you configure your ganache application to use Port Number 8545

  _Note related to recent truffle update:
  A few days ago truffle updated to 5.0.29, and one of the project dependencies for unit tests (`openzeppelin-test-helpers`) presented some issues. The dependency was updated and this issue is supposed to be fixed now, but if when trying to run it locally you find an error related to the web3 version, make sure you install truffle 5.0.28, using the commands below:_

  ```.sh
  npm uninstall -g truffle
  npm install -g truffle@5.0.28
  ```

###### Front-end

- A web browser that supports Metamask like Google Chrome, Firefox or Opera
- Install [Metamask Extension](https://metamask.io/)

#### 2 - Clone the repo to your desired folder

```.sh
git clone https://github.com/fodisi/hackapay.git
```

#### 3 - Move to the project folder, install dependencies and setup config files

```.sh
cd hackapay
npm install
mv credentials-sample.js credentials.js // Required, otherwise truffle compile will fail
```

## Running the project locally

#### Smart Contracts

You can use the following commands to compile, migrate and test the smart contracts:

- compile: `truffle compile`
- migrate: `truffle migrate` (migrate to ganache instance on localhost - don't forget configure ganache to use it to use Port Number 8545)
- run unit tests: `truffle test`

#### Running Web dev-server to serve the Front-End

You'll need to run the following command to start you local dev-server. Once the project is compiled, a webbrowser should open automatically on your local machine. The local dev-server runs at `http://localhost:8080/`

Start web dev-server: `npm run start`

#### Additional commands:

##### Deploying contracts to Testnets (ropsten and kovan)

This project uses [Infura]() infrastructure to deploy the contracts to ETH testnets. You'd need to register with Infura and create a project id. Once you have the credentials, follow these steps:

- Open file `credentials.js`
- Insert your Infura ProjectId and mnemonic in the file for the desired network
- Once you have the credentials file properly setup, run the following commands to deploy the contracts to ropsten and/or kovan:
  - Deploy to ropsten: `npm run deploy:ropsten`
  - Deploy to kovan: `npm run deploy:kovan`

##### Run test coverage

This project uses [solidity-coverage](https://www.npmjs.com/package/solidity-coverage) for testing coverage. You can check the test coverage by running the following command:
`npm run coverage`

##### Run security Analysis

This project uses [truffle-security](https://github.com/ConsenSys/truffle-security) to analyze potential exploits.
To run a full analysis, you'll need to create an account with [MythX](https://mythx.io/), and use the ETH Address and Password provided.
Once you have the ETH Address and password from MythX, open the file [mythx-config-sample.sh](mythx-config-sample.sh). Insert the ETH Address and password provided, and run execute the exports (with the appropriate ETH address and password) on you command line

```.sh
export MYTHX_ETH_ADDRESS=YOUR_MYTHX_ETH_ADDRESS
export MYTHX_PASSWORD='MYTHX_PASSWORD'
```

After setting up your credentials, you can run the following command:
`npm run verify-security` or `truffle run verify`
