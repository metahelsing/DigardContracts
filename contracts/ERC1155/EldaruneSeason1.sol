// contracts/EldaruneSeason1.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./token/IDigardERC1155.sol";
import "../Security/DigardAccessControl.sol";
import "./token/DigardERC1155.sol";
import "./extensions/DigardERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EldaruneSeason1 is DigardERC1155, DigardERC1155Burnable, DigardAccessControl, Ownable, IDigardERC1155 {
    
    
    constructor() DigardERC1155("https://cdn.digard.io/Eldarune/Season1/Metadata/Erc1155/", "Eldarune Season 1", "ELDSEASON1") {}

    function addMinterRole(address account) public onlyOwner {
         grantMintRole(account);
    }

    function mintItem(address account, uint256 id, uint256 amount) 
        public onlyRole(MINT_ROLE)
    {
        _mint(account, id,  amount, "");
    }

    function mintBatchItem(address account, uint256[] memory ids, uint256[] memory amounts) 
        public onlyRole(MINT_ROLE)
    {
        _mintBatch(account, ids, amounts, "");
    }

     function burnItem(
        address account,
        uint256 id,
        uint256 value
    ) public virtual override {
        super.burn(account, id, value);
    }

    function burnBatchItem(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual override {
       super.burnBatch(account, ids, values);
    }
}