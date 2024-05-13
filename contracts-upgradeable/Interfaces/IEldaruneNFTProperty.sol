// SPDX-License-Identifier: MIT
// Digard Contracts (last updated v1.0.0) (Interfaces/IEldaruneNFTProperty.sol)

pragma solidity ^0.8.12;
interface IEldaruneNFTProperty {

    enum Rarity {
        Uncommon,
        Common,
        Rare,
        Epic,
        Legendary
    }

    struct TokenProperty {
        uint256 tokenId;
        uint256 level;
        Rarity rarity;
    }

    function getTokenProperty(uint256 tokenId) external view returns(TokenProperty memory);
   
}