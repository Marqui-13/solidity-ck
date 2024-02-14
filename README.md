# CryptoKids - A Solidity Smart Contract for Managing Kids' Allowances

CryptoKids is a blockchain-based solution designed to manage allowances for kids in a secure, transparent, and automated way. Built on the Ethereum blockchain, it allows parents (or guardians) to set aside funds that are released to their kids at a predetermined time, teaching them about savings and financial responsibility.

## Features

- Add Kids: Securely add kid profiles with allowance details, controlled by the contract owner (typically a parent or guardian).
- Deposit Funds: Deposit ether into the contract, earmarked for each kid.
- Automated Allowance Release: Funds become available for withdrawal by the kid after a specified release time.
- Withdraw Funds: Kids can withdraw their allowances to their own wallets upon reaching the release time.
- Ownership Control: Functions that manage kids and their allowances are restricted to the contract owner.

## Technology Stack

- Solidity ^0.8.7: For the smart contract development.
- Ethereum Blockchain: For deploying and running the contract.

## Smart Contract Functions

- `addKid(address payable walletAddress, string memory firstName, string memory lastName, uint releaseTime, uint amount, bool canWithdraw)`: Adds a new kid profile to the contract.
- `balanceOf()`: Returns the contract's current ether balance.
- `deposit(address walletAddress) payable`: Deposits funds to the contract under a specific kid's account.
- `availableToWithdraw(address walletAddress)`: Checks if funds are available for withdrawal by the kid.
- `withdraw(address payable walletAddress) payable`: Allows a kid to withdraw their funds.

## Deployment

To deploy this contract to the Ethereum blockchain, follow these steps:

1. Ensure you have Ethereum for gas fees and an Ethereum wallet (e.g., MetaMask).
2. Use a Solidity development environment like Remix IDE for compilation and deployment.
3. Deploy the contract to your desired network (Ethereum mainnet or testnet).

## Interacting with the Contract

After deployment, interact with the contract through:

- Web3 libraries like Web3.js or Ethers.js to integrate contract interaction into your dApp.
- Direct interaction in Remix IDE or through Ethereum wallets that support smart contract interaction for manual operations.

### Examples:

- Parent (Owner) Operations: Use `addKid` to set up a new allowance, `deposit` to add funds, and `balanceOf` to check the contract's balance.
- Kid Operations: Use `availableToWithdraw` to check if funds are available and `withdraw` to transfer the allowance to their wallet.

## Security Considerations

- Ensure that the contract is thoroughly tested before deploying on the mainnet, especially functions that involve transferring funds.
- Consider potential gas cost implications when interacting with the contract, particularly for functions that iterate over arrays.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE) file for details.

## Acknowledgments

- Ethereum and Solidity documentation for providing foundational knowledge and best practices in smart contract development.