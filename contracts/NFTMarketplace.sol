// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _marketItemIds;
    Counters.Counter private _itemsSold;

    struct MarketItem {
        uint256 marketItemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
    }

    mapping(uint256 => MarketItem) private marketIdToMarketItem;

    event MarketItemCreated(
        uint256 indexed marketItemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price
    );

    function getMarketItem(uint256 marketItemId)
        public
        view
        returns (MarketItem memory)
    {
        return marketIdToMarketItem[marketItemId];
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public nonReentrant {
        require(price > 0, "Price must be at least 1 wei!");
        _marketItemIds.increment();
        uint256 marketItemId = _marketItemIds.current();
        marketIdToMarketItem[marketItemId] = MarketItem(
            marketItemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price
        );
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        emit MarketItemCreated(
            marketItemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price
        );
    }

    function createMarketSale(address nftContract, uint256 marketItemId)
        public
        payable
        nonReentrant
    {
        uint256 price = marketIdToMarketItem[marketItemId].price;
        uint256 tokenId = marketIdToMarketItem[marketItemId].tokenId;
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );
        marketIdToMarketItem[marketItemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        marketIdToMarketItem[marketItemId].owner = payable(msg.sender);
        _itemsSold.increment();
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _marketItemIds.current();
        uint256 unsoldItemCount = _marketItemIds.current() -
            _itemsSold.current();
        uint256 currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (marketIdToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = marketIdToMarketItem[i + 1].marketItemId;
                MarketItem memory currentItem = marketIdToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _marketItemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (marketIdToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (marketIdToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = marketIdToMarketItem[i + 1].marketItemId;
                MarketItem memory currentItem = marketIdToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
