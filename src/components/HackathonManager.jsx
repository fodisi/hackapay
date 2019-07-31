import React, {Component} from "react";
import {Form, Input, Button, ToastMessage, PublicAddress, Text, Heading} from "rimble-ui";

import HackathonFactoryWrapper from "../integration/HackathonFactoryWrapper";

class HackathonManager extends Component {
  constructor() {
    super();
    this.state = {
      hackathons: [],
      name: "",
      description: "",
      id: -1,
    };
  }

  componentDidMount = () => {
    this.factory = new HackathonFactoryWrapper(this.props.web3, this.props.networkId);
  };

  getHackathonAddressById = async () => {
    try {
      if (this.state.id < 0) {
        throw new Error("Invalid id");
      }
      this.props.setProcessing(true);
      const address = await this.factory.getHackathonContractById(this.state.id);
      console.log(address);
      this.setState({hackathons: [address]});
      this.props.setProcessing(false);
    } catch (error) {
      console.log("customerror", error);
      this.props.setError(
        "Unable to retrieve contract address. Check the id used. Error: " + error.message,
        error.stack
      );
      this.props.setProcessing(false);
    }
  };

  createHackathon = async () => {
    try {
      this.props.setProcessing(true);
      const result = await this.factory.createHackathonContract(this.state.name, this.state.description, {
        from: this.props.account,
      });
      const {returnValues} = result.events.NewHackathonContract;
      this.setState({
        info: `New Hackathon created. Id: "${returnValues.id}. Address: "${returnValues.contractAddress}"`,
      });
      console.log(result);
      this.props.setProcessing(false);
    } catch (error) {
      this.props.setError("Unable to create contract. Check the id used. Error: " + error.message, error.stack);
      this.props.setProcessing(false);
    }
  };

  render() {
    let addresses = [];
    const {hackathons} = this.state;

    if (hackathons && Array.isArray(hackathons)) {
      addresses = hackathons.map((item, index) => (
        <PublicAddress key={index} address={item} label="Contract address:" />
      ));
    }

    return (
      <Form style={{marginTop: "50px"}}>
        <Heading.h3>Hackathon Factory</Heading.h3>
        <Heading.h6>Deploy new Hackathon contracts and retrieve the deployed contract address</Heading.h6>
        <div style={{marginTop: "30px"}}>
          <Text>Fill out name and description and click New Hackathon to deploy a new Hackathon contract</Text>
          <Input
            placeholder="Hackathon Name"
            required={true}
            type="text"
            onChange={(e) => this.setState({name: e.target.value})}
          />
          <Input
            placeholder="Hackathon Description"
            required={true}
            type="text"
            onChange={(e) => this.setState({description: e.target.value})}
          />
          <Button type="button" onClick={this.createHackathon}>
            {"New hackathon"}
          </Button>
          {this.state.info && (
            <React.Fragment>
              <ToastMessage.Success my={3} message={"Success"} />
              <Text>{this.state.info}</Text>
              <Button onClick={() => this.setState({info: ""})}>Close message</Button>
            </React.Fragment>
          )}
        </div>
        <div style={{marginTop: "30px"}}>
          <Text>Fill out id and click on Get Hackathon to retrieve the contract address by Hackathon id</Text>
          <Input
            placeholder="Hackathon Id"
            required={true}
            type="text"
            onChange={(e) => this.setState({id: e.target.value !== "" ? e.target.value : -1})}
          />

          <Button type="button" onClick={this.getHackathonAddressById}>
            {"Get hackathon"}
          </Button>

          {addresses && addresses.length > 0 && <div>{addresses}</div>}
        </div>
      </Form>
    );
  }
}

export default HackathonManager;
