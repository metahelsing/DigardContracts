// SPDX-License-Identifier: MIT
// Digard Contracts (last updated v1.0.0) (Interfaces/IDigardClaim.sol)

pragma solidity ^0.8.12;

interface IDigardClaim {
    function addPlayerToken(address playerAddress, uint256 amount) external;

    function addPlayerClaimNft(
        address playerAddress,
        uint256 nftContractIndex,
        uint256 tokenId,
        uint256 amount
    ) external;

    function getRewardContractIndex(
        address addr
    ) external view returns (int256);

    function getRewardContractByIndex(
        uint256 index
    ) external view returns (address);
}
