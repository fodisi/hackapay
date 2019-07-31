import React, {Component} from "react";
import {ThemeProvider, Form} from "rimble-ui";

import Header from "./Header.jsx";
import HackathonManager from "./HackathonManager";

import getWeb3 from "../utils/getWeb3";

class App extends Component {
  constructor() {
    super();
    this.state = {
      processing: false,
    };
  }

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({web3, accounts, networkId}, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(`Failed to load web3, accounts, or contract. Check console for details.`);
      console.error(error);
    }
  };

  setProcessing = (status) => {
    this.setState({processing: status});
  };

  render() {
    return (
      <ThemeProvider>
        <React.Fragment>
          <Header processing={this.state.processing} />
          {!this.state.web3 && <p>{"Loading"}</p>}
          {this.state.web3 && (
            <Form>
              <HackathonManager
                web3={this.state.web3}
                accounts={this.state.accounts}
                networkId={this.state.networkId}
              />
            </Form>
          )}
        </React.Fragment>
      </ThemeProvider>
    );
  }
}

export default App;
