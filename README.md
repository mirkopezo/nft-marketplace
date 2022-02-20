# NFT Marketplace

NFT marketplace is a site where you can sell and buy NFTs (Non-Fungible Tokens).

Currently, this project doesn’t have any front-end, but you can interact with it using an Etherscan or other tools like Remix, Hardhat, etc.
Marketplace contract is verified and deployed to Rinkeby Testnet: https://rinkeby.etherscan.io/address/0x7323286C89Da482a12cFF01a8A71C64eF180B902.

## How to sell NFT
Before selling your NFT, you need to approve the NFT marketplace contract address by calling approve("0x7323286C89Da482a12cFF01a8A71C64eF180B902", TOKEN_ID) or setApprovalForAll("0x7323286C89Da482a12cFF01a8A71C64eF180B902", true) on your ERC-721 contract.
You need to do this because the NFT marketplace will transfer your NFT to its address, and it needs to have approval for this transfer.

Or you can use my NFT contract (NFT.sol) to deploy your ERC-721 and then mint your NFT. This contract, by default, approves the NFT marketplace when minting NFT.

Then if you want to sell your NFT, you need to call function createMarketItem() and input your ERC-721 contract address, token ID, and desired price.

## How to buy NFT
If you want to buy NFT, you just need to call createMarketSale() and input the ERC-721 contract address, token ID and send a price that the seller set for that NFT.
