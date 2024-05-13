pragma solidity ^0.8.0;

import "./interfaces/IERC2981.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

abstract contract RoyaltyRegistry is IERC2981, ERC721Upgradeable {
    
    mapping (uint256 => address) private _tokenRoyaltyReceivers;
    mapping (uint256 => uint256) private _tokenRoyaltyBPS;
    
    function setTokenRoyalty(uint256 tokenId, address receiver, uint256 basisPoints) public {
        require(basisPoints <= 10000, "Basis points should not be greater than 10000.");
        require(msg.sender == ownerOf(tokenId), "Only token owner can set royalty.");
        _tokenRoyaltyReceivers[tokenId] = receiver;
        _tokenRoyaltyBPS[tokenId] = basisPoints;
    }
    
    function royaltyInfo(uint256 tokenId, uint256 value) external view override returns (address receiver, uint256 royaltyAmount) {
        uint256 basisPoints = _tokenRoyaltyBPS[tokenId];
        if (basisPoints > 0) {
            receiver = _tokenRoyaltyReceivers[tokenId];
            royaltyAmount = (value * basisPoints) / 10000;
        }
    }
    
}