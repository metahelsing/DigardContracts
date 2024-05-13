// SPDX-License-Identifier: MIT
// Digard Contracts v1.0 (utils/RandomNumber.sol)
pragma solidity ^0.8.0;

library Randomize {
    struct Random {
        uint256 _increment;
    }

    function newRandomNumber(
        Random storage random,
        uint maxRandom
    ) internal returns (uint256) {
        random._increment += 1;
        uint r = uint(
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        random._increment
                    )
                )
            ) % maxRandom
        );
        return r;
    }

    function newNonZeroRandomNumber(
        Random storage random,
        uint maxRandom
    ) internal returns (uint256) {
        uint256 randomNumber = newRandomNumber(random, maxRandom);
        if (randomNumber == 0) {
            randomNumber += 1;
        }
        return randomNumber;
    }
}
