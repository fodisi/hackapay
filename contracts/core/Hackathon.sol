pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./ContestBracketRegistry.sol";
import "../payment/Payable.sol";

/**
    @notice Represents a hackathon contest, where organizers can control the
    stages/phases of the contest (such as registration, submission, evaluation and results)
    as well as pay prizes to the winners.
    @dev For the payment functionality, the "withdraw pattern" is being implemented for this contract.
    The ledger allocation is done is the method {allocatePrize} and the withdraw is implemented on {withdrawPrize}.
 */
contract Hackathon is Payable, ContestBracketRegistry {
    using SafeMath for uint256;

    /// @dev Represents a prize to be paid to a winner.
    struct Prize {
        uint256 amount;
        bool paid;
    }

    uint256 public id;
    bytes32 public name;
    bytes32 public description;
    Prize internal firstPlacePrize;
    Prize internal secondPlacePrize;
    Prize internal thirdPlacePrize;
    bool internal prizesAllocated;

    /// @dev emitted when the prize allocation is performed. This may be used to alert winners that their prizes are available to withdraw.
    event PrizeAllocation(
        uint256 firstPlacePrize,
        uint256 secondPlacePrize,
        uint256 thirdPlacePrize,
        address indexed organizer,
        uint256 datetime
    );

    /// @dev emitted when a prize is withdraw by a winner team.
    event Withdraw(address indexed to, uint256 amount, uint8 rankPosition, address indexed requester, uint256 datetime);

    modifier whenPrizeNotAllocated() {
        require(!prizesAllocated, "Prizes already allocated");
        _;
    }

    modifier whenPrizeAllocated() {
        require(prizesAllocated, "Prizes not allocated yet");
        _;
    }

    modifier onlyWinnerAddress(address winnerAddress) {
        require(isWinnerAddress(winnerAddress), "Account address is not a winner");
        _;
    }

    modifier onlyValidAddress(address account) {
        require(account != address(0), "Invalid zero address");
        require(account != address(this), "Address cannot be equal to contract (this) address");
        _;
    }

    constructor(uint256 _id, bytes32 _name, bytes32 _description, address initialOrganizer)
        public
        ContestBracketRegistry(initialOrganizer)
    {
        require(_name[0] != 0, "Invalid name");
        id = _id;
        name = _name;
        description = _description;
        prizesAllocated = false;
    }

    /**
        @notice Allows the organizer to allocate funds that's going to be distributed to winners.
        @dev It does not associate the prize with a specific account, since prizes cound be associated any moment
        by the organizers, as long as prizes were not allocated before.
        The contract needs to have enought balance to allocate funds to winners.
     */
    function allocatePrize(uint256 firstPrize, uint256 secondPrize, uint256 thirdPrize)
        external
        onlyOrganizer
        whenPrizeNotAllocated
    {
        uint256 totalPrizes = firstPrize.add(secondPrize).add(thirdPrize);
        require(totalPrizes <= address(this).balance, "Not enough funds available in hackathon contract");
        firstPlacePrize = Prize(firstPrize, false);
        secondPlacePrize = Prize(secondPrize, false);
        thirdPlacePrize = Prize(thirdPrize, false);
        prizesAllocated = true;
        emit PrizeAllocation(firstPrize, secondPrize, thirdPrize, msg.sender, now);
    }

    /**
        @notice Allows withdrawing prizes to winners.
        @dev Winners must implement IPayable to receive funds.
     */
    function withdrawPrize(address winnerAddress)
        external
        whenRankPublished
        whenPrizeAllocated
        onlyValidAddress(winnerAddress)
        onlyWinnerAddress(winnerAddress)
    {
        address teamAddress;
        uint256 amount;
        uint8 rankPosition;

        if (winnerAddress == firstPlace.teamAddress) {
            teamAddress = firstPlace.teamAddress;
            amount = firstPlacePrize.amount;
            rankPosition = 1;
            require(!firstPlacePrize.paid, "Prize already paid for first place");
            firstPlacePrize.paid = true;
        } else if (winnerAddress == secondPlace.teamAddress) {
            teamAddress = secondPlace.teamAddress;
            amount = secondPlacePrize.amount;
            rankPosition = 2;
            require(!secondPlacePrize.paid, "Prize already paid for second place");
            secondPlacePrize.paid = true;
        } else if (winnerAddress == thirdPlace.teamAddress) {
            teamAddress = thirdPlace.teamAddress;
            amount = thirdPlacePrize.amount;
            rankPosition = 3;
            require(!thirdPlacePrize.paid, "Prize already paid for third place");
            thirdPlacePrize.paid = true;
        } else {
            revert("Invalid address. Address check failed. Should not reach this point.");
        }

        emit Withdraw(teamAddress, amount, rankPosition, msg.sender, now);
        // Pays winner using team addres.
        IPayable(teamAddress).deposit.value(amount)();
    }

    function isWinnerAddress(address winnerAddress) private view returns (bool) {
        return (
            winnerAddress == firstPlace.teamAddress ||
                winnerAddress == secondPlace.teamAddress ||
                winnerAddress == thirdPlace.teamAddress
        );
    }
}
