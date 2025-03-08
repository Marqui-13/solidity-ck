# CryptoKids Smart Contract

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

`CryptoKids` is a Solidity smart contract designed to manage allowances for kids on the Ethereum blockchain. It enables an owner (e.g., a parent) to register kids with wallet addresses, assign timed allowances, and control withdrawal permissions. Kids can withdraw funds once conditions are met, offering a practical demonstration of blockchain-based financial management.

This contract serves as a portfolio piece to showcase advanced Solidity and Yul expertise, featuring optimized assembly code, secure Ether handling, and a clean, modular design. It is not intended for production deployment but highlights best practices and technical proficiency.

## Features

- **Kid Management**: Register and update kids with names, release times, amounts, and withdrawal permissions.
- **Timed Allowances**: Funds are locked until a specified `releaseTime` and require `canWithdraw` approval.
- **Flexible Withdrawals**: Kids can withdraw partial or full amounts of their allocated funds.
- **Yul Optimization**: Uses assembly for dynamic storage updates and efficient Ether transfers.
- **Secure Design**: Integrates OpenZeppelin’s `ReentrancyGuard` and enforces fund allocation.
- **Transparency**: Comprehensive events and view functions for state tracking.
- **Emergency Control**: Owner can withdraw unallocated funds, reflecting parental oversight.

## Contract Details

- **Solidity Version**: `^0.8.7`
- **License**: MIT
- **Dependencies**: OpenZeppelin Contracts (`ReentrancyGuard`)
- **File**: `CryptoKids.sol`

### Key Functions

#### Owner Functions
- `addKid`: Registers a new kid with initial allowance and conditions.
- `updateKid`: Modifies a kid’s release time and withdrawal permission.
- `deposit`: Adds funds to a kid’s allowance.
- `emergencyWithdraw`: Withdraws unallocated funds to the owner.
- `updateOwner`: Transfers ownership to a new address.

#### Kid Functions
- `withdraw`: Allows a kid to withdraw a specified amount, optimized with Yul.

#### View Functions
- `balanceOf`: Returns the contract’s total Ether balance.
- `getKid`: Retrieves a kid’s details (name, release time, amount, etc.).
- `availableToWithdraw`: Checks if a kid can withdraw funds.
- `getTotalAllocated`: Shows the total funds allocated to kids.

#### Internal Utilities
- `safeTransferETH`: Handles Ether transfers with Yul, optimized for flexibility.

## Setup

To explore this contract locally:

### Prerequisites
- [Node.js](https://nodejs.org/) (for Hardhat)
- [Hardhat](https://hardhat.org/) (development framework)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) (via npm)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Marqui-13/solidity-ck
   cd cryptokids
   ```
2. Install dependencies:
   ```bash
   npm install
   npm install @openzeppelin/contracts
   ```
3. Place `CryptoKids.sol` in `contracts/`.

### Compilation
```bash
npx hardhat compile
```

## Testing Ideas

Demonstrate the contract’s functionality with these scenarios:

1. **Kid Registration**:
   - Add a kid and verify event emission and state updates.
   - Attempt duplicate registration (should fail).

2. **Allowance Management**:
   - Deposit Ether for a kid and check `totalAllocated`.
   - Update a kid’s `releaseTime` and `canWithdraw`.

3. **Withdrawal**:
   - Try withdrawing before `releaseTime` (should fail).
   - Advance time and withdraw partially, verifying Yul updates.

4. **Security**:
   - Test reentrancy on `withdraw` (blocked by `nonReentrant`).
   - Send Ether via `receive` as a non-kid (should fail).

5. **Emergency Withdrawal**:
   - Send excess Ether and confirm only unallocated funds are withdrawn.

### Example Hardhat Test
```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CryptoKids", function () {
  it("Adds kid and withdraws funds", async function () {
    const CryptoKids = await ethers.getContractFactory("CryptoKids");
    const contract = await CryptoKids.deploy();
    await contract.deployed();

    const kidAddr = "0x1234...";
    await contract.addKid(kidAddr, "Alice", "Smith", Math.floor(Date.now() / 1000) + 3600, ethers.utils.parseEther("1"), true);
    await contract.deposit(kidAddr, { value: ethers.utils.parseEther("0.5") });

    const kid = await contract.getKid(kidAddr);
    expect(kid.amount).to.equal(ethers.utils.parseEther("1.5"));
  });
});
```
## Testing with Remix IDE

In addition to Hardhat, you can test `CryptoKids` using [Remix IDE](https://remix.ethereum.org/), an online tool for Solidity development:

1. **Open Remix**: Visit [remix.ethereum.org](https://remix.ethereum.org/).
2. **Create File**: In the File Explorer, create a new file (e.g., `CryptoKids.sol`) and paste the contract code.
3. **Compile**: Go to the "Solidity Compiler" tab, select version `0.8.7`, and click "Compile CryptoKids.sol".
4. **Deploy**: Switch to the "Deploy & Run Transactions" tab, choose "JavaScript VM" (or another environment), and deploy the contract.
5. **Interact**: Use the deployed contract interface to call functions like `addKid`, `deposit`, and `withdraw`, adjusting time via Remix’s VM controls to test `releaseTime`.

Remix is ideal for quick testing without local setup, offering a built-in VM and debugging tools to explore the contract’s behavior.

## Design Choices

- **Yul Assembly**: Optimized `withdraw` with dynamic slot computation and `safeTransferETH` with full gas forwarding, showcasing low-level control.
- **Reentrancy Safety**: Relies on `nonReentrant` for `safeTransferETH`, balancing flexibility and security.
- **Fund Tracking**: `totalAllocated` ensures accurate emergency withdrawals.
- **Modifiers**: Enhances readability and reduces code duplication.
- **Events**: Provides full auditability for key actions.

## Security Considerations

- **Reentrancy**: Prevented by `ReentrancyGuard` and state updates before external calls.
- **Yul Safety**: Dynamic slot calculations and explicit underflow checks ensure correctness.
- **Fund Integrity**: `receive` enforces allocation, though `selfdestruct` funds remain an EVM limitation.

## Limitations

- Funds sent via `selfdestruct` may be withdrawn by the owner as unallocated.
- Relies on honest block timestamps (minor miner manipulation possible).
- Centralized owner control reflects parental oversight, not trustlessness.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.

## Contact

Reach out via GitHub Issues for feedback or questions! <br>
GitHub: @Marqui-13<br>
Email: marquivionorr@proton.me

