// SPDX-License-Identifier: MIT
// Digard Contracts (last updated v1.0.0) (Interfaces/IDigardNFTWhitelist.sol)

pragma solidity ^0.8.12;

interface IDigardNFTWhitelist {
    function getWhitelist(
        address whitelistAddress,
        address tokenAddress,
        uint256 tokenId
    ) external view returns (bool);
}
