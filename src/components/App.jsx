import React, {Component} from "react";
import {ThemeProvider, Loader, Text} from "rimble-ui";

import Header from "./Header.jsx";
import HackathonManager from "./HackathonManager.jsx";
import ContestTeamManager from "./ContestTeamManager.jsx";
import ErrorBoundary from "./ErrorBoundary.jsx";
import getWeb3 from "../utils/getWeb3";

class App extends Component {
  constructor() {
    super();
    this.state = {
      processing: false,
      web3: undefined,
      accounts: [],
      networkId: 0,
      balance: 0,
      error: "",
      errorInfo: "",
    };
  }

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();
      this.setState({web3}, await this.updateNetworkAndAccountInfo(web3));
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(`Failed to load web3, accounts, or contract. Check console for details.`);
      console.error(error);
    }

    const that = this;

    window.ethereum.on("accountsChanged", async (accounts) => {
      //Lazy reload
      await this.updateNetworkAndAccountInfo(that.state.web3);
    });

    window.ethereum.on("networkChanged", async (netId) => {
      //Lazy reload
      await this.updateNetworkAndAccountInfo(that.state.web3);
    });

    //FIXME: Not performing, but does the job.
    that.state.web3.eth.subscribe("newBlockHeaders", (err, _) => {
      if (err) {
        console.log(`newBlockHeaders subscription error: ${err}`);
      } else {
        // Update balance
        that.state.web3.eth.getBalance(that.state.accounts[0], (err, bal) => {
          if (err) {
            console.log(`getBalance error: ${err}`);
          } else {
            const balance = that.state.web3.utils.fromWei(bal, "ether");
            that.setState({balance: balance});
            console.log(`Balance [${that.state.accounts[0]}]: ${balance}`);
          }
        });
      }
    });
  };

  updateNetworkAndAccountInfo = async (web3) => {
    // Use web3 to get the user's accounts.
    const accounts = await web3.eth.getAccounts();

    // Get the contract instance.
    const networkId = await web3.eth.net.getId();

    const balance = await web3.eth.getBalance(accounts[0]);

    // Set web3, accounts, and contract to the state.
    this.setState({accounts, networkId, balance: web3.utils.fromWei(balance, "ether")});
  };

  setProcessing = (status) => {
    this.setState({processing: status});
  };

  setError = (error, errorInfo) => {
    this.setState({error, errorInfo});
  };

  closeError = () => {
    this.setError(undefined, undefined);
  };

  render() {
    const {accounts, web3, networkId, processing, error, errorInfo, balance} = this.state;

    return (
      <ThemeProvider>
        <React.Fragment>
          <Header
            processing={processing}
            account={accounts && accounts.length > 0 ? accounts[0] : ""}
            networkId={networkId}
            balance={balance.toString()}
          />
          <ErrorBoundary error={error} errorInfo={errorInfo} close={this.closeError} style={{margin: "30px 0px 0px"}} />
          {!this.state.web3 && <p>{"Loading"}</p>}
          {this.state.web3 && (
            <div>
              <HackathonManager
                web3={web3}
                account={accounts[0]}
                networkId={networkId}
                setProcessing={this.setProcessing}
                setError={this.setError}
              />
              <ContestTeamManager
                web3={web3}
                account={accounts[0]}
                networkId={networkId}
                setProcessing={this.setProcessing}
                setError={this.setError}
              />
            </div>
          )}
          {this.state.processing && (
            <div style={{width: "100%", margin: "50px 45% 0px"}}>
              <Loader size="60px" />
              <Text>Processing... Make sure you open Metamask and approve the transaction</Text>
            </div>
          )}
        </React.Fragment>
      </ThemeProvider>
    );
  }
}

export default App;
