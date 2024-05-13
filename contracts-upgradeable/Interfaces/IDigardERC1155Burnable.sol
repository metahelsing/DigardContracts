// SPDX-License-Identifier: MIT
// Digard Contracts (last updated v1.0.0) (Interfaces/IDigardERC1155Burnable.sol)

pragma solidity ^0.8.12;
interface IDigardERC1155Burnable {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external;
    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external;
   
}