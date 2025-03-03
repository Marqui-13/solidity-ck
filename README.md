# CryptoKids: A Solidity Smart Contract for Kids’ Allowances

**CryptoKids** is a blockchain-based smart contract designed to securely manage and automate kids’ allowances. Built on the Ethereum blockchain, it allows parents or guardians to set aside funds that are released to their kids at predetermined times, promoting financial responsibility and savings habits.

# Features

**Add Kid Profiles** – Securely add a kid’s wallet address, name, release date, and allowance details.<br>
**Deposit Funds** – Parents or guardians can deposit Ether directly into the contract, earmarked for a specific kid.<br>
**Automated Allowance Release** – Funds are released based on a predefined date, ensuring kids access their money only when permitted.<br>
**Withdrawal by Kids** – Kids can withdraw their funds to their own wallets upon meeting eligibility conditions.<br>
**Secure & Transparent** – Built on Ethereum’s blockchain for immutability, decentralization, and security.<br>

# How It Works

1. **Contract Deployment** – A parent or guardian deploys the contract, automatically becoming the contract’s owner.
2. **Adding a Kid** – The owner adds a kid’s profile by specifying their wallet address, names, release time, and initial allowance amount.
3. **Depositing Funds** – Anyone can deposit Ether for a specific kid, and the amount is recorded in their profile.
4. **Checking Allowance** – Kids can check if they are eligible to withdraw their funds based on the preset release time.
5. **Withdrawing Funds** – Eligible kids can withdraw their funds to their personal wallet.

# Technical Details
	•	**Solidity Version:** ^0.8.7
	•	**Ethereum Blockchain:** Deployed on Ethereum for decentralized security and transparency
	•	**Gas Optimizations:** Uses mappings instead of arrays for efficient lookups

# Smart Contract Functions

## Owner Functions
	•	addKid(address walletAddress, string memory firstName, string memory lastName, uint releaseTime, uint amount, bool canWithdraw)
	•	Adds a kid’s profile. Only the contract owner can add a kid.
	•	updateOwner(address newOwner)
	•	Transfers ownership to a new address.

## Allowance Management
	•	balanceOf() – Returns the contract’s Ether balance.
	•	deposit(address walletAddress) – Deposits Ether for a specific kid’s wallet.
	•	availableToWithdraw(address walletAddress) – Checks if the kid is eligible to withdraw.
	•	withdraw(address payable walletAddress) – Allows a kid to withdraw their funds when eligible.

## Emergency & Fallback Functions
	•	emergencyWithdraw() – Allows the owner to withdraw all contract funds in case of an emergency.
	•	receive() – Accepts direct Ether deposits into the contract.

# Deployment and Interaction

## How to Deploy

**1. Pre-requisites:**<br>
	•	Install MetaMask or another Ethereum wallet<br>
	•	Have sufficient Ether for gas fees<br>
**2. Deploy the Contract:**<br>
	•	Use Remix IDE, Hardhat, or another Solidity environment<br>
	•	Deploy the contract to Ethereum mainnet or testnet (Goerli, Sepolia, etc.)<br>
**3. Interact with the Contract:**<br>
	•	Use Remix IDE, Etherscan, or a Web3 library (Web3.js, Ethers.js)<br>

# Security Considerations

**Reentrancy Protection** – Uses the checks-effects-interactions pattern to prevent reentrancy attacks.<br>
**Access Control** – Owner-restricted functions ensure only authorized users can modify contract state.<br>
**Gas Griefing Protection** – Uses .send instead of .call to prevent malicious gas exhaustion.<br>
**Emergency Withdrawals** – The owner can recover funds in case of persistent transfer failures.<br>

⚠ **Disclaimer:** Although this contract follows security best practices, **it is highly recommended to conduct professional audits and thorough testing before deploying on mainnet**.

# License

This project is open-source and licensed under the MIT License.