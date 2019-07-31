#Hackapay

###Deploy

#####Main and test nets with infura
rename credentials-sample.js to credentials.js
`mv credentials-sample.js credentials.js`
configure the project id and mnemonic

          <Text>Hackathon attendees:</Text>
          <Text>Have you ever been to a Blockchain hackathon where you worked really hard to be a winner</Text>
          <Text> and at the end, figure out the prizes are paid months later in digital currency? Cash?</Text>
          <Text>or even worse... gift cards?</Text>
          <br />
          <Text>Hackathon organizers:</Text>
          <Text>Have you ever organized a Hackathon and found yourself struggling to keep track of</Text>
          <Text>or trying to figure out how to:</Text>
          <Text> - keep track of attendees registration and team formattion</Text>
          <Text> - control the submission process</Text>
          <Text> - provide transparency during the evaluation process</Text>
          <Text> - publish the results; and/or</Text>
          <Text> - provide transparency about the prizes you want to distribute as an incentive</Text>
          <Text> - distribute the prizes winner`s team members?</Text>

          <Text>HackaPay aims to provide a single platform to manage hackathons (more contests in the future)</Text>
          <Text>facilitating and helping organizers to better manage their hackathons, while prodiving better</Text>
          <Text>transparency for attendees about prizes, evaluations, final results...</Text>
          <Text>and the best for attendees: faster payment of prizes.</Text>
          <Text>The UI is still under construction, but you can `Factories` of the network, responsible</Text>
          <Text>for deploying and keeping track of the contracts created by users:</Text>
          <Text> - The Hackathon Factory: Deploys a Hackathon contract to the blockchain, that will be used</Text>
          <Text> managing ang interacting with the hackathon (registration, proposal submission, evaluation, </Text>
          <Text> publishing results, and distributing prizes to winner teams (ContestTeam contracts)</Text>
          <Text> - The Contest Team Factory: Deploys a ContesteTeam contract to the blockchain, that will be used</Text>
          <Text> manage team members, withdraw prizes to and distribute prizes among team members.</Text>
          <br/>
          <Text>The current UI, only interacts with the contract Factories, allowing the creation of new </Text>
          <Text>hackathons and teams, and retrieving the addresses for the contracts deployed.</Text>
          <Text>The UI still needs to implement the functionality to interact with the contracts</Text>
          <Text>created and deployed dinamically by the uses (Hackathon and ContestTeam contracts).</Text>
