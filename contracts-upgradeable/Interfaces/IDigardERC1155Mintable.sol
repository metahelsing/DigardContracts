// SPDX-License-Identifier: MIT
// Digard Contracts (last updated v1.0.0) (ERC1155/token/IDigardERC1155Mintable.sol)

pragma solidity ^0.8.12;
interface IDigardERC1155Mintable {
    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
   
}