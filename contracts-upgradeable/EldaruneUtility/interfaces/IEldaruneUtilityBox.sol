// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEldaruneUtilityBox {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function burnForUpgrade(uint256 tokenId) external;
    function safeMint(address to,string memory uri) external returns (uint256);
    
}