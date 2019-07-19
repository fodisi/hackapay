pragma solidity ^0.5.0;

import "../roles/OrganizerRole.sol";

contract Hackathon is OrganizerRole {
    uint256 public id;
    bytes32 public name;
    bytes32 public description;

    constructor(uint256 _id, bytes32 memory _name, bytes32 memory _description) public {
        require(name != "", "Invalid name");
        id = _id;
        name = _name;
        description = _description;
    }

    // TODO: Add judges

}
