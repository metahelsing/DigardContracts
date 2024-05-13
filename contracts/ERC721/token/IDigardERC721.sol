// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IDigardERC721.sol)

pragma solidity ^0.8.12;
interface IDigardERC721 {
    function mintItem(address account, uint256 id) external;
    function burnItem(uint256 id) external;
}