pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BSCBridge is ERC721 {
    uint256 public tokenCounter;
    bool _resulter;
    constructor() ERC721("NFT Mint Bridge", "NFTMB") {
        tokenCounter = 0;
    }

    function resulter(bool result) public {
        _resulter = result;
    }
     function getResulter() public view returns(bool){
        return _resulter;
    }
    function mint()
        public
        returns (uint256)
    {
        
        _safeMint(msg.sender, 1);
        //_setTokenURI(newTokenId, tokenURI);
      
        return 1;
    }
}