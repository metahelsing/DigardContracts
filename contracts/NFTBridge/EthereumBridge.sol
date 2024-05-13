pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./BSCBridge.sol";

contract EthereumBridge {
    address public admin;
    IERC721 public nftContract;
    address public bscContractAddress;

    constructor(address _nftContract, address _bscMintBridge) {
        admin = msg.sender;
        nftContract = IERC721(_nftContract);
        bscContractAddress = _bscMintBridge;
    }

    function transfer() public {
        require(
            nftContract.ownerOf(1) == msg.sender,
            "You do not own this token"
        );
        bytes4 functionSignature1 = bytes4(keccak256("resulter(bool)"));
        bytes memory data1 = abi.encodeWithSignature("resulter(bool)", true);
        (bool success1, ) = bscContractAddress.call(abi.encodePacked(functionSignature1, data1));

        bytes4 functionSignature = bytes4(keccak256("mint(address)"));
        bytes memory data = abi.encodeWithSignature("mint(address)", msg.sender);
        (bool success, ) = bscContractAddress.call(abi.encodePacked(functionSignature, data));
        require(success, "Failed to call BSC contract");
        
    }
}