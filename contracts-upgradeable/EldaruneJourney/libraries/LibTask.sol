// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

struct Task {
    uint256 taskGroupId;
    uint256 taskId;
    uint[3] lockTime;
    uint256 numberOfRepetitions;
    uint256 successRate;
}

struct Reward {
    uint256 claimRewardContractIndex;
    uint256 tokenId;
    uint256 amount;
    address tokenAddress;
}

struct Subscribe {
    uint256 subscribeId;
    uint256 taskId;
    uint256 startTime;
    uint256 startBlockNumber;
    bool active;
}

struct RequirementNft {
    address tokenAddress;
    uint256 tokenId;
    uint256 amount;
    uint256 burnRate;
}

struct RequirementToken {
    address tokenAddress;
    uint256 amount;
}

struct LockedRequirementNft {
    address tokenAddress;
    uint256 tokenId;
    uint256 amount;
    uint256 burnRate;
}
