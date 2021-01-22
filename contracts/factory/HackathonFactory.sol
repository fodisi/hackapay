// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../core/Hackathon.sol";

/**
    @notice A factory to deploy new Hackathon contracts, and provide functionality to retrieve the deployed contracts' addresses.
    @dev TODO: use struct to keep record of hackathon names, and allow implementing upgradability.
 */
contract HackathonFactory {
    using SafeMath for uint256;

    address[] private deployedHackathons;
    mapping(bytes32 => address) private hackathonsByName;

    /// @dev emitted when a new Hackathon contract is deployed.
    event NewHackathonContract(uint256 id, bytes32 name, bytes32 description, address contractAddress, address creator);
    // event TeamContractDeployed(uint256 id, bytes32 name, address contractAddress, address creator);

    /// @dev Modifier to check if hackathon name is not empty.
    modifier notEmptyName(bytes32 name) {
        require(name[0] != 0, "Hackathon name cannot be empty");
        _;
    }

    /// @dev Modifier to check if hackathon name is unique.
    modifier uniqueHackathonName(bytes32 name) {
        require(hackathonsByName[name] == address(0), "Hackathon name already in use");
        _;
    }

    /**
    @notice Creates and deploys a new Hackathon contract.
    @param name Unique hackathon's name.
    @param description A short description for the Hackathon.
    @return The new contract's address.
    */
    function createHackathonContract(bytes32 name, bytes32 description)
        public
        payable
        notEmptyName(name)
        uniqueHackathonName(name)
        returns (address)
    {
        // TODO: insert check if the sent ether is enough to cover the car asset ...
        uint256 id = deployedHackathons.length;
        address newHackathon = address(new Hackathon(id, name, description, msg.sender));
        deployedHackathons.push(newHackathon);
        hackathonsByName[name] = newHackathon;
        emit NewHackathonContract(id, name, description, newHackathon, msg.sender);
        return newHackathon;
    }

    /**
        @notice Get a list with the addresses of the deployed contracts.
        @return List of deployed contract's addresses 
    */
    function getDeployedHackathonContracts() public view returns (address[] memory) {
        return deployedHackathons;
    }

    /**
        @notice Get a contract address with the internal id.
        @return An address representing a deployed contract
    */
    function getHackathonContractById(uint256 id) public view returns (address) {
        require(id < deployedHackathons.length);
        return deployedHackathons[id];
    }

    /**
        @notice Get a contract address with the internal name.
        @return An address representing a deployed contract
    */
    function getHackathonContractByName(bytes32 name) public view notEmptyName(name) returns (address) {
        return hackathonsByName[name];
    }
}
