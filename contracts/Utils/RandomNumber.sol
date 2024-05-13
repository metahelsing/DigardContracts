// SPDX-License-Identifier: MIT
// Digard Contracts v1.0 (utils/RandomNumber.sol)
pragma solidity ^0.8.0;

library Randomize {
    struct Random {
        uint256 _increment;
    }

    function newRandomNumber(Random storage random) internal returns (uint256) {
        random._increment += 1;
        return uint(keccak256(abi.encodePacked(random._increment))) % 100;
    }

    function newNonZeroRandomNumber(
        Random storage random
    ) internal returns (uint256) {
        uint256 randomNumber = newRandomNumber(random);
        while (randomNumber == 0) {
            randomNumber = newRandomNumber(random);
        }
        return randomNumber;
    }
}
