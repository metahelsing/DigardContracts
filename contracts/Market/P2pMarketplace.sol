// contracts/DigardMarketplace.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract P2pMarketplace is ReentrancyGuard, ERC1155Receiver
{
  using Counters for Counters.Counter;
  Counters.Counter private _itemCounter;//start from 1
  Counters.Counter private _itemSoldCounter;

  address payable public marketowner;
  uint256 public listingFee = 0.025 ether;
  

  enum State { Created, Release, Inactive }

  struct MarketItem {
    uint id;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable buyer;
    uint256 price;
    string  tokenStandart;
    address spendingContract;
    State state;
  }

  mapping(uint256 => MarketItem) private marketItems;

  event MarketItemCreated (
    uint indexed id,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address buyer,
    uint256 price,
    string tokenStandart,
    address spendingContract,
    State state
  );

  event MarketItemSold (
    uint indexed id,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address buyer,
    uint256 price,
    string tokenStandart,
    address spendingContract,
    State state
  );

  constructor() {
    marketowner = payable(msg.sender);
  }

  /**
   * @dev Returns the listing fee of the marketplace
   */
  function getListingFee() public view returns (uint256) {
    return listingFee;
  }
  
  function getItemFee(uint256 id) public view returns (uint256) {
    return marketItems[id].price;
  }
  
  function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external virtual override returns (bytes4) {
      return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
  }

  function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external virtual override returns (bytes4) {
      return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
  }
  /**
   * @dev create a MarketItem for NFT sale on the marketplace.
   * 
   * List an NFT.
   */
  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    address spendingContract,
    uint256 price
  ) public payable nonReentrant {

    require(price > 0, "Price must be at least 1 wei");
    require(msg.value == listingFee, "Fee must be equal to listing fee");

    _itemCounter.increment();
    uint256 id = _itemCounter.current();
    string memory tokenStandart = "";
  
    if(IERC165(nftContract).supportsInterface(type(IERC721).interfaceId)){
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        tokenStandart = "ERC721";
    }
    else if (IERC165(nftContract).supportsInterface(type(IERC1155).interfaceId)){
        IERC1155(nftContract).safeTransferFrom(msg.sender, address(this), tokenId, 1, msg.data);
        tokenStandart = "ERC1155";
    }
   
    marketItems[id] =  MarketItem(
      id,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price,
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
  function deleteMarketItem(uint256 itemId) public nonReentrant {
    require(itemId <= _itemCounter.current(), "id must <= item count");
    require(marketItems[itemId].state == State.Created, "item must be on market");
    MarketItem storage item = marketItems[itemId];

    if(IERC165(item.nftContract).supportsInterface(type(IERC721).interfaceId)){
        require(IERC721(item.nftContract).ownerOf(item.tokenId) == msg.sender, "must be the owner");
    }
    else if(IERC165(item.nftContract).supportsInterface(type(IERC1155).interfaceId)){
        require(IERC1155(item.nftContract).balanceOf(msg.sender, item.tokenId) > 0, "must be the owner");
    }
    

    item.state = State.Inactive;

    emit MarketItemSold(
      itemId,
      item.nftContract,
      item.tokenId,
      item.seller,
      address(0),
      0,
      item.tokenStandart,
      item.spendingContract,
      State.Inactive
    );

  }

  /**
   * @dev (buyer) buy a MarketItem from the marketplace.
   * Transfers ownership of the item, as well as funds
   * NFT:         seller    -> buyer
   * value:       buyer     -> seller
   * listingFee:  contract  -> marketowner
   */
  function createMarketSale(uint256 id) public payable nonReentrant {

    MarketItem storage item = marketItems[id]; //should use storge!!!!
    uint price = item.price;
    uint tokenId = item.tokenId;
    
    require(IERC20(item.spendingContract).balanceOf(msg.sender) >= price, "Insufficient balance");
    //require(msg.value == price, "Please submit the asking price");
    
    item.buyer = payable(msg.sender);
    item.state = State.Release;
    _itemSoldCounter.increment();    

    

    if(IERC165(item.nftContract).supportsInterface(type(IERC721).interfaceId)){
        IERC721(item.nftContract).transferFrom(address(this), msg.sender, tokenId);
    }
    else if(IERC165(item.nftContract).supportsInterface(type(IERC1155).interfaceId)){
        IERC1155(item.nftContract).safeTransferFrom(address(this), msg.sender, tokenId, 1, msg.data);
    }
    
    payable(marketowner).transfer(listingFee);
    IERC20(item.spendingContract).transferFrom(item.buyer, item.seller, price);

    //item.seller.transfer(msg.value);

    emit MarketItemSold(
      id,
      item.nftContract,
      tokenId,
      item.seller,
      msg.sender,
      price,
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

  enum FetchOperator { ActiveItems, MyPurchasedItems, MyCreatedItems}

  /**
   * @dev fetch helper
   * todo pagination   
   */
   function fetchHepler(FetchOperator _op) private view returns (MarketItem[] memory) {     
    uint total = _itemCounter.current();

    uint itemCount = 0;
    for (uint i = 1; i <= total; i++) {
      if (isCondition(marketItems[i], _op)) {
        itemCount ++;
      }
    }

    uint index = 0;
    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 1; i <= total; i++) {
      if (isCondition(marketItems[i], _op)) {
        items[index] = marketItems[i];
        index ++;
      }
    }
    return items;
  } 

  /**
   * @dev helper to build condition
   *
   * todo should reduce duplicate contract call here
   * (IERC721(item.nftContract).getApproved(item.tokenId) called in two loop
   */
  function isCondition(MarketItem memory item, FetchOperator _op) private view returns (bool){
    if(_op == FetchOperator.MyCreatedItems){ 
      return 
        (item.seller == msg.sender
          && item.state != State.Inactive
        )? true
         : false;
    }else if(_op == FetchOperator.MyPurchasedItems){
      return
        (item.buyer ==  msg.sender) ? true: false;
    }else if(_op == FetchOperator.ActiveItems){
      return 
        (item.buyer == address(0) 
          && item.state == State.Created
         
        )? true
         : false;
    }else{
      return false;
    }
  }

}