// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract CryptoKids {
    address private owner;

    event KidAdded(address indexed walletAddress, string firstName, string lastName, uint releaseTime, uint amount, bool canWithdraw);
    event LogKidFundingReceived(address indexed addr, uint amount, uint contractBalance);
    event LogWithdrawal(address indexed addr, uint amount);
    event WithdrawalFailed(address indexed addr, uint amount);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event EmergencyWithdrawal(address indexed owner, uint amount);

    struct Kid {
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    mapping(address => Kid) private kids;
    mapping(address => bool) private isKid; // Tracks if a wallet is registered

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier onlyKid(address walletAddress) {
        require(msg.sender == walletAddress, "Unauthorized: Only kid can withdraw");
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function updateOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function addKid(address walletAddress, string memory firstName, string memory lastName, uint releaseTime, uint amount, bool canWithdraw) public onlyOwner {
        require(walletAddress != address(0), "Invalid wallet address");
        require(!isKid[walletAddress], "Kid already exists");

        kids[walletAddress] = Kid(firstName, lastName, releaseTime, amount, canWithdraw);
        isKid[walletAddress] = true;

        emit KidAdded(walletAddress, firstName, lastName, releaseTime, amount, canWithdraw);
    }

    function balanceOf() public view returns (uint) {
        return address(this).balance;
    }

    function deposit(address walletAddress) public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        require(isKid[walletAddress], "Kid not found");

        kids[walletAddress].amount += msg.value;
        emit LogKidFundingReceived(walletAddress, msg.value, address(this).balance);
    }

    function availableToWithdraw(address walletAddress) public view returns (bool) {
        require(isKid[walletAddress], "Kid not found");
        Kid storage kid = kids[walletAddress]; // Saves gas by reducing storage reads
        return block.timestamp > kid.releaseTime && kid.canWithdraw;
    }

    function withdraw(address payable walletAddress) public onlyKid(walletAddress) {
        require(isKid[walletAddress], "Kid not found");
        Kid storage kid = kids[walletAddress]; // Gas optimization
        require(availableToWithdraw(walletAddress), "Withdrawal conditions not met");
        require(kid.amount > 0, "No funds available");
        require(kid.amount <= address(this).balance, "Insufficient contract balance");

        uint amountToWithdraw = kid.amount;
        kid.amount = 0; // Update state before sending

        // Using `send` instead of `call` to avoid gas griefing and always handle failure cases
        if (!walletAddress.send(amountToWithdraw)) {
            kid.amount = amountToWithdraw; // Restore funds if send fails
            emit WithdrawalFailed(walletAddress, amountToWithdraw);
        } else {
            emit LogWithdrawal(walletAddress, amountToWithdraw);
        }
    }

    function emergencyWithdraw() public onlyOwner {
        uint contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds available");

        (bool sent, ) = payable(owner).call{value: contractBalance}("");
        require(sent, "Emergency withdrawal failed");

        emit EmergencyWithdrawal(owner, contractBalance);
    }

    receive() external payable {
        emit LogKidFundingReceived(msg.sender, msg.value, address(this).balance);
    }
}