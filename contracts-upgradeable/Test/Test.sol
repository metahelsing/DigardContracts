// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract Test {
    struct StakingInformation {
        uint256 stakingSubscribeId;
        uint256 stakingProgramId;
        uint256 tokenId;
        uint256 amount;
        uint256 startTime;
        bool active;
    }
    mapping(address => StakingInformation[]) public _stakingSubscribes;

    function saveStakingSubscribe(
        StakingInformation memory _stakingInformation,
        address playerAddress
    ) public {
        _stakingSubscribes[playerAddress].push(_stakingInformation);
    }

    function removeStakingSubscribe(address playerAddress) public {
        delete _stakingSubscribes[playerAddress][1];
    }

    function getStakingSubscribe(
        address playerAddress
    ) public view returns (StakingInformation[] memory) {
        return _stakingSubscribes[playerAddress];
    }
}
