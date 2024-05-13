// contracts/DigardMarketplace.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../ERC1155/token/IDigardERC1155.sol";
import "../ERC721/token/IDigardERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DigardGameMarket is ReentrancyGuard, ERC1155Receiver, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemCounter; //start from 1
    Counters.Counter private _itemSoldCounter;

    address payable public marketowner;

    enum State {
        Created,
        Release,
        Inactive
    }

    struct MarketItem {
        uint256 id;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable buyer;
        uint256 price;
        uint256 remaingAmount;
        bool isRemaing;
        string tokenStandart;
        address spendingContract;
        State state;
    }

    mapping(uint256 => MarketItem) private marketItems;

    event MarketItemCreated(
        uint256 indexed id,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price,
        uint256 remaingAmount,
        string tokenStandart,
        address spendingContract,
        State state
    );

    event MarketItemSold(
        uint256 indexed id,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price,
        uint256 amount,
        uint256 remaingAmount,
        string tokenStandart,
        address spendingContract,
        State state
    );

    constructor() {
        marketowner = payable(msg.sender);
    }

    function setMarketOwner(address _marketowner) public onlyOwner {
        marketowner = payable(_marketowner);
    }

    function getItemFee(uint256 id) public view returns (uint256) {
        return marketItems[id].price;
    }

    function setMarketItem(
        uint256 id,
        uint256 price,
        uint256 remainingAmount
    ) public onlyOwner {
        marketItems[id].price = price;
        marketItems[id].remaingAmount = remainingAmount;
    }

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external virtual override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external virtual override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    /**
     * @dev create a MarketItem for NFT sale on the marketplace.
     *
     * List an NFT.
     */
    function ListMarketItem(
        address nftContract,
        uint256 tokenId,
        address spendingContract,
        uint256 price,
        uint256 remaining,
        bool isRemaining
    ) public payable nonReentrant onlyOwner {
        require(price > 0, "Price must be at least 1 wei");

        _itemCounter.increment();
        uint256 id = _itemCounter.current();
        string memory tokenStandart = "";

        if (IERC165(nftContract).supportsInterface(type(IERC721).interfaceId)) {
            tokenStandart = "ERC721";
        } else if (
            IERC165(nftContract).supportsInterface(type(IERC1155).interfaceId)
        ) {
            tokenStandart = "ERC1155";
        }
        require(controlMarketItem(nftContract, tokenId) == false, "");

        marketItems[id] = MarketItem(
            id,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            remaining,
            isRemaining,
            tokenStandart,
            spendingContract,
            State.Created
        );

        emit MarketItemCreated(
            id,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            remaining,
            tokenStandart,
            spendingContract,
            State.Created
        );
    }

    /**
     * @dev delete a MarketItem from the marketplace.
     *
     * de-List an NFT.
     *
     * todo ERC721.approve can't work properly!! comment out
     */
    function DeleteMarketItem(uint256 itemId) public nonReentrant onlyOwner {
        require(itemId <= _itemCounter.current(), "id must <= item count");
        require(
            marketItems[itemId].state == State.Created,
            "item must be on market"
        );
        MarketItem storage item = marketItems[itemId];

        item.state = State.Inactive;

        emit MarketItemSold(
            itemId,
            item.nftContract,
            item.tokenId,
            item.seller,
            address(0),
            0,
            0,
            item.remaingAmount,
            item.tokenStandart,
            item.spendingContract,
            State.Inactive
        );
    }

    function getTotalPrice(uint256 id, uint256 amount)
        public
        view
        returns (uint256)
    {
        MarketItem storage item = marketItems[id];
        uint256 totalPrice = item.price * amount;
        return totalPrice;
    }

    /**
     * @dev (buyer) buy a MarketItem from the marketplace.
     * Transfers ownership of the item, as well as funds
     * NFT:         seller    -> buyer
     * value:       buyer     -> seller
     * listingFee:  contract  -> marketowner
     */
    function SaleMarketItem(uint256 id, uint256 amount)
        public
        payable
        nonReentrant
    {
        MarketItem storage item = marketItems[id]; //should use storge!!!!
        uint256 price = item.price;
        uint256 tokenId = item.tokenId;

        uint256 totalPrice = price * amount;

        if (item.isRemaing) {
            require(item.remaingAmount > amount, "Insufficient quantity");
        }
        require(
            IERC20(item.spendingContract).allowance(
                msg.sender,
                address(this)
            ) >= totalPrice,
            "Insufficient balance"
        );

        item.buyer = payable(msg.sender);
        item.state = State.Release;
        _itemSoldCounter.increment();

        if (
            IERC165(item.nftContract).supportsInterface(
                type(IERC721).interfaceId
            )
        ) {
            IDigardERC721(item.nftContract).mintItem(item.buyer, tokenId);
        } else if (
            IERC165(item.nftContract).supportsInterface(
                type(IERC1155).interfaceId
            )
        ) {
            IDigardERC1155(item.nftContract).mintItem(
                item.buyer,
                tokenId,
                amount
            );
        }

        IERC20(item.spendingContract).transferFrom(
            item.buyer,
            marketowner,
            totalPrice
        );

        if (item.isRemaing) {
            item.remaingAmount -= amount;
        }

        emit MarketItemSold(
            id,
            item.nftContract,
            tokenId,
            item.seller,
            msg.sender,
            totalPrice,
            amount,
            item.remaingAmount,
            item.tokenStandart,
            item.spendingContract,
            State.Release
        );
    }

    /**
     * @dev Returns all unsold market items
     * condition:
     *  1) state == Created
     *  2) buyer = 0x0
     *  3) still have approve
     */
    function fetchActiveItems() public view returns (MarketItem[] memory) {
        return fetchHepler(FetchOperator.ActiveItems);
    }

    /**
     * @dev Returns only market items a user has purchased
     * todo pagination
     */
    function fetchMyPurchasedItems() public view returns (MarketItem[] memory) {
        return fetchHepler(FetchOperator.MyPurchasedItems);
    }

    /**
     * @dev Returns only market items a user has created
     * todo pagination
     */
    function fetchMyCreatedItems() public view returns (MarketItem[] memory) {
        return fetchHepler(FetchOperator.MyCreatedItems);
    }

    enum FetchOperator {
        ActiveItems,
        MyPurchasedItems,
        MyCreatedItems
    }

    function controlMarketItem(address nftContract, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        uint256 total = _itemCounter.current();
        bool isAny = false;

        for (uint256 i = 1; i <= total; i++) {
            if (
                marketItems[i].nftContract == nftContract &&
                marketItems[i].tokenId == tokenId
            ) {
                isAny = true;
            }
        }
        return isAny;
    }

    /**
     * @dev fetch helper
     * todo pagination
     */
    function fetchHepler(FetchOperator _op)
        private
        view
        returns (MarketItem[] memory)
    {
        uint256 total = _itemCounter.current();

        uint256 itemCount = 0;
        for (uint256 i = 1; i <= total; i++) {
            if (isCondition(marketItems[i], _op)) {
                itemCount++;
            }
        }

        uint256 index = 0;
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 1; i <= total; i++) {
            if (isCondition(marketItems[i], _op)) {
                items[index] = marketItems[i];
                index++;
            }
        }
        return items;
    }

    function getMarketIdByTokenId(uint256 tokenId)
        public
        view
        onlyOwner
        returns (uint256)
    {
        uint256 total = _itemCounter.current();
        uint256 marketId=0;
        for (uint256 i = 1; i <= total; i++) {
            if (
                marketItems[i].tokenId == tokenId
            ) {
               marketId = i;
            }
        }
        return marketId;
    }

    /**
     * @dev helper to build condition
     *
     * todo should reduce duplicate contract call here
     * (IERC721(item.nftContract).getApproved(item.tokenId) called in two loop
     */
    function isCondition(MarketItem memory item, FetchOperator _op)
        private
        view
        returns (bool)
    {
        if (_op == FetchOperator.MyCreatedItems) {
            return
                (item.seller == msg.sender && item.state != State.Inactive)
                    ? true
                    : false;
        } else if (_op == FetchOperator.MyPurchasedItems) {
            return (item.buyer == msg.sender) ? true : false;
        } else if (_op == FetchOperator.ActiveItems) {
            return
                (item.buyer == address(0) && item.state == State.Created)
                    ? true
                    : false;
        } else {
            return false;
        }
    }
}
