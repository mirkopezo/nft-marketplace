const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarketplace", function () {
  let marketplaceAddress;
  let nftAddress;
  let nft;
  let marketplace;
  let addr1, addr2;

  beforeEach(async function () {
    const Marketplace = await ethers.getContractFactory("NFTMarketplace");
    marketplace = await Marketplace.deploy();
    await marketplace.deployed();
    marketplaceAddress = marketplace.address;

    const Nft = await ethers.getContractFactory("NFT");
    nft = await Nft.deploy("MirkoCollection", "MIC", marketplaceAddress);
    await nft.deployed();
    nftAddress = nft.address;

    [addr1, addr2] = await ethers.getSigners();
  });

  it("Should create marketplace items correctly", async function () {
    await nft.mint("a");
    await nft.mint("b");
    await nft.mint("c");

    await marketplace.createMarketItem(nftAddress, 1, 500);
    await marketplace.createMarketItem(nftAddress, 2, 1000);
    await marketplace.createMarketItem(nftAddress, 3, 750);

    items = await marketplace.fetchMarketItems();
    expect(items[0].marketItemId).to.equal(1);
    expect(items[1].marketItemId).to.equal(2);
    expect(items[2].marketItemId).to.equal(3);

    expect(items[0].nftContract).to.equal(nftAddress);
    expect(items[1].nftContract).to.equal(nftAddress);
    expect(items[2].nftContract).to.equal(nftAddress);

    expect(items[0].tokenId).to.equal(1);
    expect(items[1].tokenId).to.equal(2);
    expect(items[2].tokenId).to.equal(3);

    expect(items[0].seller).to.equal(addr1.address);
    expect(items[1].seller).to.equal(addr1.address);
    expect(items[2].seller).to.equal(addr1.address);

    expect(items[0].owner).to.equal(
      "0x0000000000000000000000000000000000000000"
    );
    expect(items[1].owner).to.equal(
      "0x0000000000000000000000000000000000000000"
    );
    expect(items[2].owner).to.equal(
      "0x0000000000000000000000000000000000000000"
    );

    expect(items[0].price).to.equal(500);
    expect(items[1].price).to.equal(1000);
    expect(items[2].price).to.equal(750);
  });

  it("Should create market sale (happy path)", async function () {
    await nft.mint("a");

    await marketplace.createMarketItem(nftAddress, 1, 500);

    await expect(
      await marketplace
        .connect(addr2)
        .createMarketSale(nftAddress, 1, { value: 500 })
    ).to.changeBalance(addr1, 500);

    item = await marketplace.getMarketItem(1);

    expect(item.owner).to.equal(addr2.address);
  });

  it("Should not create market sale (unhappy path)", async function () {
    await nft.mint("a");

    await marketplace.createMarketItem(nftAddress, 1, 500);

    await expect(
      marketplace.connect(addr2).createMarketSale(nftAddress, 1, { value: 495 })
    ).to.be.revertedWith(
      "Please submit the asking price in order to complete the purchase"
    );

    item = await marketplace.getMarketItem(1);

    expect(item.owner).to.equal("0x0000000000000000000000000000000000000000");
  });
});
