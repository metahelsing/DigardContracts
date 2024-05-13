// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (Chest/EldaChest.sol)

pragma solidity ^0.8.12;

contract EldaChest {

    enum ChestType {
        Character,
        Item
    }
    
    struct Chest {
        uint256 id;
        string name;

    }
}