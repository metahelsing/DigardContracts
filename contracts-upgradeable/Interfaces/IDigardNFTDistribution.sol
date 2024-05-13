// SPDX-License-Identifier: MIT
// Digard Contracts (last updated v1.0.0) (Interfaces/IDigardNFTDistribution.sol)

pragma solidity ^0.8.12;
interface IDigardNFTDistribution {
    struct PlayerItem {
        address playerAddress;
        uint256[] tokenIds;
        uint256[] amounts;
    }

}