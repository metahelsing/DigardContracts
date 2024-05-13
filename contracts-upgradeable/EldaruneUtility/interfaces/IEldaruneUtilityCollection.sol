// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEldaruneUtilityCollection {
    function getTokenLevelByTokenId(uint256 _tokenId) external view returns (uint);
    
}