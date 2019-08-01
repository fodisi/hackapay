/* global window */

import HackathonFactoryContract from "../../build/contracts/HackathonFactory.json";

class HackathonFactory {
  constructor(web3, networkId) {
    this.web3 = web3;
    const deployedNetwork = HackathonFactoryContract.networks[networkId];
    const instance = new web3.eth.Contract(HackathonFactoryContract.abi, deployedNetwork && deployedNetwork.address);
    this.contract = instance;
  }

  getHackathonContracts = async () => {
    const result = this.contract.methods.getDeployedHackathonContracts().call();
    return result;
  };

  createHackathonContract = async (name, description, options) => {
    const byteName = this.web3.utils.asciiToHex(name, 32);
    const byteDescription = this.web3.utils.asciiToHex(description, 32);
    return await this.contract.methods.createHackathonContract(byteName, byteDescription).send({from: options.from});
  };
}

export default HackathonFactory;
