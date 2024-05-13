// SPDX-License-Identifier: MIT
// Digard Contracts (last updated v1.0.0) (ERC721/extensions/DigardERC721Burnable.sol)

pragma solidity ^0.8.12;

import "../token/DigardERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be burned (destroyed).
 */
abstract contract DigardERC721Burnable is Context, DigardERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _burn(tokenId);
    }
}