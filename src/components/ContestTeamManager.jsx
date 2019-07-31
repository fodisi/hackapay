import React, {Component} from "react";
import {Form, Input, Button, ToastMessage, PublicAddress, Text, Heading} from "rimble-ui";

import ContestTeamFactoryWrapper from "../integration/ContestTeamFactoryWrapper";

class TeamManager extends Component {
  constructor() {
    super();
    this.state = {
      teams: [],
      name: "",
      id: -1,
    };
  }

  componentDidMount = () => {
    this.factory = new ContestTeamFactoryWrapper(this.props.web3, this.props.networkId);
  };

  getTeamAddressById = async () => {
    try {
      if (this.state.id < 0) {
        throw new Error("Invalid id");
      }
      this.props.setProcessing(true);
      const address = await this.factory.getTeamContractById(this.state.id);
      console.log(address);
      this.setState({teams: [address]});
      this.props.setProcessing(false);
    } catch (error) {
      console.log("customerror", error);
      this.props.setError(error.message, error.callStack);
      this.props.setProcessing(false);
    }
  };

  createTeam = async () => {
    try {
      this.props.setProcessing(true);
      const result = await this.factory.createTeamContract(this.state.name, {from: this.props.account});
      const {returnValues} = result.events.NewContestTeamContract;
      this.setState({
        info: `New Team created. Id: "${returnValues.id}. Address: "${returnValues.contractAddress}"`,
      });
      console.log(result);
      this.props.setProcessing(false);
    } catch (error) {
      this.props.setError(error.message, error.callStack);
      this.props.setProcessing(false);
    }
  };

  render() {
    let addresses = [];
    const {teams} = this.state;

    if (teams && Array.isArray(teams)) {
      addresses = teams.map((item, index) => <PublicAddress key={index} address={item} label="Contract address:" />);
    }

    return (
      <Form style={{marginTop: "50px"}}>
        <Heading.h3>Team Factory</Heading.h3>
        <Heading.h6>Deploy new Team contracts and retrieve the deployed contract address</Heading.h6>
        <div style={{marginTop: "30px"}}>
          <Text>Fill out name and description and click New Team to deploy a new ContestTeam contract</Text>
          <Input
            placeholder="Team Name"
            required={true}
            type="text"
            onChange={(e) => this.setState({name: e.target.value})}
            // value={this.state.name}
          />
          <Button type="button" onClick={this.createTeam}>
            {"New team"}
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
          <Text>Fill out id and click on Get Team to retrieve the contract address by Team id</Text>
          <Input
            placeholder="Team Id"
            required={true}
            type="text"
            onChange={(e) => this.setState({id: e.target.value !== "" ? e.target.value : -1})}
            // value={this.state.description}
          />

          <Button type="button" onClick={this.getTeamAddressById}>
            {"Get team"}
          </Button>

          {addresses && addresses.length > 0 && <div>{addresses}</div>}
        </div>
      </Form>
    );
  }
}

export default TeamManager;
