// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../ERC20/token/IERC20.sol";
import "../ERC20/token/IDigardERC20.sol";
import "../Security/DigardAccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EldaruneRewardPool is DigardAccessControl, Ownable, IDigardERC20 {

    event RewardDistribution (
        address indexed tokenAddress,
        address indexed playerAddress,
        uint256 indexed timestamp,
        uint256 amount
    );

    address tokenAddress;

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function addMinterRole(address account) public onlyOwner {
         grantMintRole(account);
    }

    function getReward(address playerAddress, uint256 amount) public onlyRole(MINT_ROLE) {
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "Insufficient balance");
        IERC20(tokenAddress).transfer(playerAddress, amount);
        emit RewardDistribution(tokenAddress, playerAddress, block.timestamp, amount);
    } 
}