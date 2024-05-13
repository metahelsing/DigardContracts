// contracts/Test.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../Utils/RandomNumber.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Test 
{
    using Counters for Counters.Counter;
    Counters.Counter private _abcCounter;

    using Randomize for Randomize.Random;
    Randomize.Random private _randomize;
    uint256 rNumber;

    struct Abc {
        string name;
        uint256 tokenId;
    }
    mapping(uint256=> Abc) AbcList;
    function NewRandomize() public {
       rNumber = _randomize.newRandomNumber();
    }

    function UpgradeItem(uint lucky) public view returns(uint256)
    {
         return rNumber;
    }

    function SetAbc(Abc[] memory abc) public{
        for(uint256 i = 0; i < abc.length; i++) {
           
            uint index = _abcCounter.current();
            AbcList[index] = Abc(abc[i].name, abc[i].tokenId);
             _abcCounter.increment();
        }
    }

    function viewAbc() public view returns(Abc[] memory) {
        uint total = _abcCounter.current();
        Abc[] memory items = new Abc[](total);
         for(uint256 i = 0; i < total; i++) {
            items[i] = AbcList[i];
         } 
         return items;
    }
}