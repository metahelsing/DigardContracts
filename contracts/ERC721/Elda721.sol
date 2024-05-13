
// SPDX-License-Identifier: MIT
// Digard Contracts (last updated v1.0.0) (ERC721/Elda721.sol)
pragma solidity ^0.8.12;

import "./extensions/DigardERC721Burnable.sol";
import "../Security/DigardAccessControl.sol";
import "./token/DigardERC721.sol";
import "./token/IDigardERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Elda721 is DigardERC721,IDigardERC721, DigardAccessControl, DigardERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() DigardERC721("Eldarune Season 1", "ELDSEASON1") {}

    function addMinterRole(address account) public onlyOwner {
         grantMintRole(account);
    }

    function mintItem(address account, uint256 id) 
        public 
    {
        _mint(account, id);
    }

    function burnItem(uint256 tokenId) public virtual override {
        super.burn(tokenId);
    }

}