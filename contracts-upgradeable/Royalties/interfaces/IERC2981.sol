// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC2981 {
    event RoyaltySet(uint256 indexed tokenId, address indexed recipient, uint256 value);

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount);
}