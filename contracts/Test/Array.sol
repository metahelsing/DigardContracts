// contracts/Test/Array.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "@openzeppelin/contracts/utils/Counters.sol";

contract Array {
    using Counters for Counters.Counter;
    Counters.Counter private _ItemCounter;
    uint256 abc;
    struct Item {
        string name;
        uint256 tokenId;
    }
    mapping(uint256=>Item) Items;

    function setAbc(uint256 _abc) public {
        abc = _abc;
    }

    function setItem(Item memory _item) public {
         uint256 index = _ItemCounter.current();
            Items[index] = _item;
            _ItemCounter.increment();
    }

    function setItems(Item[] memory _items) public {
        for(uint256 i = 0; i < _items.length; i++) {
            uint256 index = _ItemCounter.current();
            Items[index] = Item(_items[i].name, _items[i].tokenId);
            _ItemCounter.increment();
        }
    }

    function getItems() public view returns(Item[] memory) {
        uint256 total = _ItemCounter.current();
        Item[] memory items = new Item[](total); 
        for(uint256 i = 0; i < total; i++) {
            items[i] = Items[i];
        }
        return items;
    }
}