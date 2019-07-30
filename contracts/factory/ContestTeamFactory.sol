pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "../core/ContestTeam.sol";

/**
    @notice A factory to deploy new ContestTeam contracts, and provide functionality to retrieve the deployed contracts' addresses.
    @dev TODO: use struct to keep record of hackathon names, and allow implementing upgradability.
 */
contract ContestTeamFactory {
    using SafeMath for uint256;

    address[] private deployedTeams;
    mapping(bytes32 => address) private teamsByName;

    /// @dev emitted when a new ContestTeam contract is deployed.
    event NewContestTeamContract(uint256 id, bytes32 name, address contractAddress, address creator);

    /// @dev Modifier to check if team name is not empty.
    modifier notEmptyName(bytes32 name) {
        require(name[0] != 0, "Hackathon name already in use");
        _;
    }

    /// @dev Modifier to check if team name is unique.
    modifier uniqueTeamName(bytes32 name) {
        require(teamsByName[name] == address(0), "Team name already in use");
        _;
    }

    /**
    @notice Creates and deploys a new ContestTeam contract.
    @param name Unique team's name, used internally for identification using a human-friendly text.
    @return The new contract's address.
    @dev  The param {name} is not linked or related to the name used by a team when registering for a hackathon.
    */
    function createTeamContract(bytes32 name) public payable notEmptyName(name) uniqueTeamName(name) returns (address) {
        // TODO: insert check if the sent ether is enough to cover the car asset ...
        uint256 id = deployedTeams.length;
        address newTeam = address(new ContestTeam(msg.sender));
        deployedTeams.push(newTeam);
        teamsByName[name] = newTeam;
        emit NewContestTeamContract(id, name, newTeam, msg.sender);
        return newTeam;
    }

    /**
        @notice Get a list with the addresses of the deployed contracts.
        @return List of deployed contract's addresses 
    */
    function getDeployedTeamContracts() public view returns (address[] memory) {
        return deployedTeams;
    }

    /**
        @notice Get a contract address with the internal id.
        @return An address representing a deployed contract
    */
    function getTeamContractyId(uint256 id) public view returns (address) {
        require(id < deployedTeams.length);
        return deployedTeams[id];
    }

    /**
        @notice Get a contract address with the internal name.
        @return An address representing a deployed contract
    */
    function getTeamContractByName(bytes32 name) public view notEmptyName(name) returns (address) {
        return teamsByName[name];
    }
}
