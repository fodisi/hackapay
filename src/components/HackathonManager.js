import React, {Component} from "react";
import {PublicAddress, Form, Input, Button, ToastMessage} from "rimble-ui";

import HackathonFactory from "../integration/HackathonFactory";

class HackathonManager extends Component {
  constructor() {
    super();
    this.state = {
      hackathons: [],
    };
  }

  componentDidMount = () => {
    this.factory = new HackathonFactory(this.props.web3, this.props.networkId);
    // this.updateHackathonList();
  };

  updateHackathonList = async () => {
    const hackathons = await this.factory.getHackathonContracts();
    this.setState({hackathons});
  };

  createHackathon = async () => {
    try {
      const result = await this.factory.createHackathonContract("name1", "description1", {
        from: this.props.accounts[0],
      });
      console.log(result);
    } catch (error) {
      this.setState({error: error.message});
    }
  };

  render() {
    // const hackathons = this.state.hackathons &&  || [];
    // const addresses = hackathons.forEach((item) => <PublicAddress address={item} />);
    return (
      <React.Fragment>
        {this.state.error && (
          <ToastMessage.Failure my={3} message={"Operation failed"} secondaryMessage={this.state.error} />
        )}
        <Button type="button" onClick={() => this.createHackathon()}>
          {"New hackathon"}
        </Button>
        }
      </React.Fragment>
    );
  }
}

export default HackathonManager;
