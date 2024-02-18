// Specifies the Solidity compiler version to prevent compatibility issues
pragma solidity ^0.8.7;

// Contract declaration for managing kids' allowances on the blockchain
contract CryptoKids {
    // State variable to store the address of the contract owner
    address private owner;

    // Events to log actions on the blockchain for external observers
    event LogKidFundingReceived(address indexed addr, uint amount, uint contractBalance);
    event LogWithdrawal(address indexed addr, uint amount);
    event WithdrawalFailed(address indexed addr, uint amount);

    // Struct to hold information about each kid
    struct Kid {
        address payable walletAddress; // Kid's wallet address to receive funds
        string firstName; // First name of the kid
        string lastName; // Last name of the kid
        uint releaseTime; // Timestamp when funds can be withdrawn
        uint amount; // Amount of ether (in wei) allocated to the kid
        bool canWithdraw; // Flag to indicate if the kid can withdraw funds
    }

    // Dynamic array to store information about all kids
    Kid[] private kids;

    // Modifier to restrict function execution to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Constructor to set the contract deployer as the owner
    constructor() {
        owner = msg.sender;
    }

    // Function to add a new kid to the contract. Can only be called by the contract owner
    function addKid(address payable walletAddress, string memory firstName, string memory lastName, uint releaseTime, uint amount, bool canWithdraw) public onlyOwner {
        kids.push(Kid(walletAddress, firstName, lastName, releaseTime, amount, canWithdraw));
    }

    // Function to get the contract's balance of ether
    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

    // Function to deposit ether into the contract for a specific kid
    function deposit(address walletAddress) public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        bool kidFound = false;
        for(uint i = 0; i < kids.length && !kidFound; i++) {
            if(kids[i].walletAddress == walletAddress) {
                kids[i].amount += msg.value;
                emit LogKidFundingReceived(walletAddress, msg.value, balanceOf());
                kidFound = true;
            }
        }
        require(kidFound, "Kid not found");
    }

    // Private function to find a kid's index in the array by their wallet address
    function getIndex(address walletAddress) private view returns(uint) {
        for(uint i = 0; i < kids.length; i++) {
            if (kids[i].walletAddress == walletAddress) {
                return i;
            }
        }
        revert("Kid not found"); // Revert transaction if the kid is not found
    }

    // Function to check if the funds are available for withdrawal by the kid
    function availableToWithdraw(address walletAddress) public view returns(bool) {
        uint i = getIndex(walletAddress);
        return block.timestamp > kids[i].releaseTime && kids[i].canWithdraw;
    }

    // Function to allow a kid to withdraw their funds
    function withdraw(address payable walletAddress) public {
        uint i = getIndex(walletAddress);
        require(msg.sender == walletAddress, "Only the kid can withdraw");
        require(availableToWithdraw(walletAddress), "Not available to withdraw");
        require(kids[i].amount <= address(this).balance, "Contract does not have enough funds");

        uint amountToWithdraw = kids[i].amount;
        kids[i].amount = 0; // Update state before sending to prevent re-entrancy

        // Attempt to send the funds to the kid's wallet address
        (bool sent, ) = walletAddress.call{value: amountToWithdraw}("");
        if (sent) {
            emit LogWithdrawal(walletAddress, amountToWithdraw);
        } else {
            kids[i].amount = amountToWithdraw; // Revert state on failure
            emit WithdrawalFailed(walletAddress, amountToWithdraw);
        }
    }
}