/* global window */

import ContestTeamFactoryContract from "../../build/contracts/ContestTeamFactory.json";

class ContestTeamFactoryWrapper {
  constructor(web3, networkId) {
    this.web3 = web3;
    const deployedNetwork = ContestTeamFactoryContract.networks[networkId];
    const instance = new web3.eth.Contract(ContestTeamFactoryContract.abi, deployedNetwork && deployedNetwork.address);
    this.contract = instance;
  }

  getTeamContractById = async (id) => {
    const result = await this.contract.methods.getTeamContractById(id).call();
    return result;
  };

  createTeamContract = async (name, options) => {
    const byteName = this.web3.utils.asciiToHex(name, 32);
    return await this.contract.methods.createTeamContract(byteName).send({from: options.from});
  };
}

export default ContestTeamFactoryWrapper;
