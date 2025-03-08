// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title CryptoKids - A smart contract for managing kids' allowances with Yul optimizations
/// @notice Showcases Solidity and Yul expertise for timed allowance management
contract CryptoKids is ReentrancyGuard {
    address private owner;
    uint private totalAllocated;

    // EVENTS
    event KidAdded(address indexed walletAddress, string firstName, string lastName, uint releaseTime, uint amount, bool canWithdraw);
    event KidUpdated(address indexed walletAddress, uint newReleaseTime, bool newCanWithdraw);
    event LogKidFundingReceived(address indexed addr, uint amount, uint contractBalance);
    event LogWithdrawal(address indexed addr, uint amount);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event EmergencyWithdrawal(address indexed owner, uint amount);

    // STRUCTS
    struct Kid {
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    // MAPPINGS
    mapping(address => Kid) private kids;
    mapping(address => bool) private isKid;

    // MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier onlyKid(address walletAddress) {
        require(msg.sender == walletAddress, "Unauthorized: Only kid can withdraw");
        _;
    }

    modifier validKid(address walletAddress) {
        require(isKid[walletAddress], "Kid not found");
        _;
    }

    // CONSTRUCTOR
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // OWNER FUNCTIONS
    function updateOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function addKid(
        address walletAddress,
        string memory firstName,
        string memory lastName,
        uint releaseTime,
        uint amount,
        bool canWithdraw
    ) external onlyOwner {
        require(walletAddress != address(0), "Invalid wallet address");
        require(!isKid[walletAddress], "Kid already exists");

        kids[walletAddress] = Kid(firstName, lastName, releaseTime, amount, canWithdraw);
        isKid[walletAddress] = true;
        totalAllocated += amount;

        emit KidAdded(walletAddress, firstName, lastName, releaseTime, amount, canWithdraw);
    }

    function updateKid(address walletAddress, uint newReleaseTime, bool newCanWithdraw) external onlyOwner validKid(walletAddress) {
        Kid storage kid = kids[walletAddress];
        kid.releaseTime = newReleaseTime;
        kid.canWithdraw = newCanWithdraw;
        emit KidUpdated(walletAddress, newReleaseTime, newCanWithdraw);
    }

    function deposit(address walletAddress) external payable validKid(walletAddress) {
        require(msg.value > 0, "Deposit must be greater than 0");
        
        kids[walletAddress].amount += msg.value;
        totalAllocated += msg.value;
        emit LogKidFundingReceived(walletAddress, msg.value, address(this).balance);
    }

    function emergencyWithdraw() external onlyOwner {
        uint available = address(this).balance > totalAllocated ? address(this).balance - totalAllocated : 0;
        require(available > 0, "No unallocated funds available");

        safeTransferETH(payable(owner), available);
        emit EmergencyWithdrawal(owner, available);
    }

    // KID FUNCTIONS
    /// @notice Withdraws a specified amount using Yul for dynamic slot updates
    /// @param walletAddress The kid's wallet address (must be msg.sender)
    /// @param amount The amount to withdraw in wei
    function withdraw(address payable walletAddress, uint amount) external onlyKid(walletAddress) validKid(walletAddress) nonReentrant {
        Kid storage kid = kids[walletAddress];
        require(block.timestamp > kid.releaseTime && kid.canWithdraw, "Withdrawal conditions not met");
        require(amount > 0 && amount <= kid.amount, "Invalid withdrawal amount");
        require(amount <= address(this).balance, "Insufficient contract balance");

        // Dynamic slot computation
        uint kidAmountSlot = uint(keccak256(abi.encode(walletAddress, 2))) + 3; // Slot 2 for kids mapping, +3 for amount
        uint totalAllocatedSlot = 1; // Slot 1 for totalAllocated, for this demo slot 1 is explicit and clear but could be computed dynamically via a storage slot variable if more variables are added

        assembly {
            // Update kid.amount
            let currentAmount := sload(kidAmountSlot)
            if gt(amount, currentAmount) { revert(0, 0) }
            let newAmount := sub(currentAmount, amount)
            sstore(kidAmountSlot, newAmount)

            // Update totalAllocated
            let currentTotal := sload(totalAllocatedSlot)
            if gt(amount, currentTotal) { revert(0, 0) }
            let newTotal := sub(currentTotal, amount)
            sstore(totalAllocatedSlot, newTotal)
        }

        safeTransferETH(walletAddress, amount);
        emit LogWithdrawal(walletAddress, amount);
    }

    // VIEW FUNCTIONS
    function balanceOf() external view returns (uint) {
        return address(this).balance;
    }

    function getKid(address walletAddress) external view validKid(walletAddress) returns (
        string memory firstName,
        string memory lastName,
        uint releaseTime,
        uint amount,
        bool canWithdraw
    ) {
        Kid memory kid = kids[walletAddress];
        return (kid.firstName, kid.lastName, kid.releaseTime, kid.amount, kid.canWithdraw);
    }

    function availableToWithdraw(address walletAddress) external view validKid(walletAddress) returns (bool) {
        Kid memory kid = kids[walletAddress];
        return block.timestamp > kid.releaseTime && kid.canWithdraw;
    }

    function getTotalAllocated() external view returns (uint) {
        return totalAllocated;
    }

    // INTERNAL FUNCTIONS
    /// @notice Safely transfers ETH using Yul, relying on nonReentrant for safety
    /// @param to The recipient address
    /// @param amount The amount of ETH to transfer in wei
    function safeTransferETH(address payable to, uint amount) internal {
        assembly {
            if iszero(amount) { revert(0, 0) }
            let success := call(
                gas(),  // Use all available gas, protected by nonReentrant in withdraw function
                to,
                amount,
                0,
                0,
                0,
                0
            )
            if iszero(success) { revert(0, 0) }
        }
    }

    // FALLBACK
    receive() external payable {
        require(isKid[msg.sender], "Only kids can send Ether directly");
        kids[msg.sender].amount += msg.value;
        totalAllocated += msg.value;
        emit LogKidFundingReceived(msg.sender, msg.value, address(this).balance);
    }
}