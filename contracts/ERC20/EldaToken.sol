// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./token/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EldaToken is ERC20, Ownable {
    

    uint256 decimal = 10 ** uint256(decimals());

    enum AllocationPoolType { Treasury }

    struct Distribution {
        uint256 supply;
        uint256 reaming;
        address pool;
    }

    mapping(AllocationPoolType=> Distribution) public distributions;
    
    
    constructor(address treasuryAddress) ERC20("Eldarune", "ELDA") 
    {
       
        distributions[AllocationPoolType.Treasury] = Distribution(
            1000000000 * decimal,
            1000000000 * decimal,
            treasuryAddress
        );

        
    }

    function mintAllocation(uint256 amount) public returns (bool){
        Distribution storage _distribution = distributions[AllocationPoolType.Treasury];
        require(_distribution.pool == msg.sender, "Unmatched mint address");
        require(_distribution.reaming >= amount, "No demand can be made more than the amount of progress payment.");
        _mint(_distribution.pool, amount);
        _distribution.reaming -= amount;
       return true;
    }

    function setAllocationPool(address _pool) external onlyOwner returns (bool){
        require(_pool != address(0), "No Dead address");
        distributions[AllocationPoolType.Treasury].pool = _pool;
        return true;
    }

}