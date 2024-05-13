// contracts/MerkleTest.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleTest {
    // Our rootHash
    bytes32 public root = 0x4457cdd2340319c180abf9cf9c1df61fe722fa2192b5eaf2a5541eca9091b4ca;

    function checkValidity(bytes32[] calldata _merkleProof) public view returns (bool){
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, root, leaf), "Incorrect proof");
        return true; // Or you can mint tokens here
    }

}