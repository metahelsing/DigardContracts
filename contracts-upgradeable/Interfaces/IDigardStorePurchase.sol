// SPDX-License-Identifier: MIT
// Digard Contracts (last updated v1.0.0) (Interfaces/IDigardNFTWhitelist.sol)

pragma solidity ^0.8.12;

interface IDigardStorePurchase {
    function getTotalPurchaseAmountByAddress(
        address msgSender,
        uint256 storeItemId
    ) external view returns (uint256);

    function savePurchase(
        address msgSender,
        uint256 storeItemId,
        uint256 amount
    ) external;
}
