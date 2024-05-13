// SPDX-License-Identifier: MIT
// Digard Contracts (last updated v1.0.0) (ERC1155/token/IDigardERC1155.sol)

pragma solidity ^0.8.12;
interface IDigardERC1155 {
    function mintItem(address account, uint256 id, uint256 amount) external;
    function mintBatchItem(address account, uint256[] memory ids, uint256[] memory amounts) external;
    function burnItem(address from, uint256 id, uint256 amount) external;
    function burnBatchItem(address from, uint256[] memory ids, uint256[] memory amounts) external;
}