import React from "react";
import PropTypes from "prop-types";
import {Box, MetaMaskButton, Heading, Text} from "rimble-ui";
import {getNetworkName} from "../utils/helpers";

const Header = (props) => {
  const {account, networkId, balance} = props;
  const network = getNetworkName(networkId);
  return (
    <div>
      <Heading.h2>Welcome to Hackapay</Heading.h2>
      <Text>If you`d like more details about the project, please expand the details section below.</Text>
      <details style={{whiteSpace: "pre-wrap"}}>
        <div>
          <Text>
            <b>Hackathon attendees:</b>
          </Text>
          <Text>Have you ever attended a Blockchain hackathon where you worked really hard to be a winner</Text>
          <Text> and after scoring high, you find out prizes will be paid months later in digital currency; </Text>
          <Text> or in Cash; or even worse: in gift cards? Wasn`t it supposed to be a `Blockchain Hackathon`?</Text>
          <Text>
            <b>Hackathon organizers:</b>
          </Text>
          <Text>Have you ever organized a Hackathon and found yourself struggling to, or trying to figure out</Text>
          <Text>how to:</Text>
          <Text> - keep track of registration (attendees sign up and team formation)</Text>
          <Text> - control the submission process</Text>
          <Text> - provide transparency during the evaluation process</Text>
          <Text> - publicly publish the results; and/or</Text>
          <Text> - provide transparency about the prizes you`ll to distribute as an incentive</Text>
          <Text> - distribute the prizes to winner`s team members?</Text>
          <Text> - improve your organizer`s image by using the blockchain to distribute prizes?</Text>
          <Text>
            <b>Objective:</b>
          </Text>
          <Text>HackaPay aims to provide a single platform to manage Hackathons (other contests in the future)</Text>
          <Text>facilitating and helping organizers to better manage their Hackathon events, while providing</Text>
          <Text>transparency for attendees about prizes, evaluations, final results,</Text>
          <Text>improved transparency and credibility, better experience for attendees, and</Text>
          <Text>faster payment/distribution of prizes to winners.</Text>
          <Text>
            <b>UI:</b>
          </Text>
          <Text>The UI is still under construction, but you can interact with `Factories` of the network,</Text>
          <Text>which are responsible for deploying and keeping track of the contracts created and deployed</Text>
          <Text>by users. There are 02 Factories in the network:</Text>
          <Text> - Hackathon Factory: Deploys a Hackathon contract to the blockchain. This contract is used for</Text>
          <Text> managing ang interacting with the hackathon (registration, proposal submission, evaluation, </Text>
          <Text> publishing results, and distributing prizes to winner teams.</Text>
          <Text> - Contest Team Factory: Deploys a ContestTeam contract to the blockchain. This contract is used</Text>
          <Text> for managing team members, depositing prizes (from the Hackathon contract) and distribute </Text>
          <Text> received prizes among team members.</Text>
          <Text>
            <b>UI Limitations:</b>
          </Text>
          <Text>The current UI, only interacts with the contract Factories, allowing the creation of new </Text>
          <Text>hackathons/teams, and retrieving the addresses for the deployed contracts.</Text>
          <Text>The UI still needs to implement the functionalities to interact with the Hackathon</Text>
          <Text>and ContestTeam contracts, created and deployed dynamically by the users using the factories.</Text>
          <Text>
            <b>Testnet Deployments:</b>
          </Text>
          <Text>The contract factories are deployed on the following testnets:</Text>
          <Text italic>ROPSTEN</Text>
          <Text italic> HackathonFactory: 0x9f545806912d09367600d079228a7c23e576b9C8 </Text>
          <Text italic> ContestTeamFactory: 0x3040ab05143DD3dF6Dd7384351613AA58BE46e4d </Text>
          <Text italic>KOVAN</Text>
          <Text italic> HackathonFactory: 0x3040ab05143DD3dF6Dd7384351613AA58BE46e4d </Text>
          <Text italic> ContestTeamFactory: 0x47c679738E95dd013C4D89BE4bDC54c94db8D6b1 </Text>
        </div>
      </details>

      <Box bg="white" color="white" fontSize={4} p={3} width={[1, 1, 0.5]}>
        <MetaMaskButton.Outline size="small">
          {account
            ? `Using Metamask. Network: "${network}"; Account: ${account}; Balance: ${balance} ETH`
            : "Please open metamask and connect to your account"}
        </MetaMaskButton.Outline>
      </Box>
    </div>
  );
};

Header.defaultProps = {
  networkId: 0,
};

Header.propTypes = {
  account: PropTypes.string.isRequired,
  networkId: PropTypes.number,
  balance: PropTypes.string.isRequired,
};

export default Header;
