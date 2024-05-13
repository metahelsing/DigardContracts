// SPDX-License-Identifier: MIT
// Digard Contracts v1.0 (Claim/DigardClaim.sol)

pragma solidity ^0.8.12;
import "../ERC20/token/IDigardERC20.sol";
import "../ERC1155/token/IDigardERC1155.sol";
import "../Security/DigardAccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract DigardClaim is Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private _playerClaimCounter;
    

    struct AddressClaimItemView {
        address playerAddress;
        ClaimItem[] items;
    }

    struct ClaimItem {
        string  name;
        string  imageUrl;
        address mintContractAddress;
        uint256 amount;
        uint256 tokenId;
    }


    mapping(uint256=> address) private Addresses;
    mapping(address=> uint256) private AddressCounter;
    mapping(address => mapping(uint256=> ClaimItem)) private ClaimItems;
    //Error-Code:0xFFFF = No claim item
    //Error-Code:0xFFFE = No minter role
    
    function AddClaimItem(string memory name, string memory imageUrl, address playerAddress, uint256 amount, address mintContractAddress, uint256 tokenId) public onlyOwner{
        uint256 playerAddressClaimIndex = AddressCounter[playerAddress];
        bytes32 MINT_ROLE = keccak256("MINT_ROLE");
    
        require(IDigardAccessControl(mintContractAddress).hasRole(MINT_ROLE, address(this)), "Error-Code:0xFFFE");
        
        ClaimItems[playerAddress][playerAddressClaimIndex] = ClaimItem(
            name,
            imageUrl,
            mintContractAddress,
            amount,
            tokenId
        );

        if(playerAddressClaimIndex == 0){
            AddressCounter[playerAddress] = 1;
            uint256 addressIndex = _playerClaimCounter.current();
            Addresses[addressIndex] = playerAddress;
            _playerClaimCounter.increment();
        }
        else {
            AddressCounter[playerAddress]++;
        }
        
    }

    function MintItem() public {
        address playerAddress = msg.sender;
        uint256 playerAddressClaimIndex = AddressCounter[playerAddress];
        require(playerAddressClaimIndex > 0, "Error-Code:0xFFFF");

        for(uint256 i = 0; i < playerAddressClaimIndex; i++) {
            address _mintContractAddress = ClaimItems[playerAddress][i].mintContractAddress;
            uint256 _amount = ClaimItems[playerAddress][i].amount;
            uint256 _tokenId = ClaimItems[playerAddress][i].tokenId;
            if(_mintContractAddress != address(0) && _amount > 0){
                if(_tokenId == 0) IDigardERC20(_mintContractAddress).getReward(playerAddress, _amount);
                else IDigardERC1155(_mintContractAddress).mintItem(playerAddress, _tokenId, _amount);
                delete ClaimItems[playerAddress][i];
            }
           
        }
    }

    function clearClaimItemsByAddress(address playerAddress) public onlyOwner () {
        uint256 playerAddressClaimIndex = AddressCounter[playerAddress];
        require(playerAddressClaimIndex > 0, "Error-Code:0xFFFF");
        for(uint256 i = 0; i < playerAddressClaimIndex; i++) {
            delete ClaimItems[playerAddress][i];
        }
    }

    function _fetchClaimListByAddress(address playerAddress) private view returns(ClaimItem[] memory){
        uint256 addressCounter = AddressCounter[playerAddress];
        require(addressCounter > 0, "Error-Code:0xFFFF");
        ClaimItem[] memory items = new ClaimItem[](addressCounter);
        for(uint256 i = 0; i < addressCounter; i++) {
            if(ClaimItems[playerAddress][i].tokenId > 0 || ClaimItems[playerAddress][i].amount > 0){
                items[i] = ClaimItems[playerAddress][i];
            }
        }
        return items;
    }

    function findClaimListByAddress(address playerAddress) public view onlyOwner returns (ClaimItem[] memory)
    {
        return _fetchClaimListByAddress(playerAddress);
    }

    function fetchClaimListByAddress() public view returns(ClaimItem[] memory){
        return _fetchClaimListByAddress(msg.sender);
    }

    function fetchClaimList() public view onlyOwner returns (AddressClaimItemView[] memory) {
        uint256 total = _playerClaimCounter.current();
        AddressClaimItemView[] memory items = new AddressClaimItemView[](total);
        for(uint256 i = 0; i < total; i++) {
            address playerAddress = Addresses[i];
            ClaimItem[] memory claimItems = findClaimListByAddress(playerAddress);
            items[i] = AddressClaimItemView(playerAddress, claimItems);
        }
        return items;
    }
}