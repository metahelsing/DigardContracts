// contracts/EldaruneTicketNft.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EldaruneTicketNft is ERC1155, Ownable {
    constructor () ERC1155("https://cdn.digard.io/Eldarune/Ticket/{id}.json"){}

    using Counters for Counters.Counter;
    Counters.Counter private _ticketItemCounter;//start from 1
    
    enum State { AddClaimList, RemoveClaimList }

    struct TicketItem {
        uint256 tokenId;
        address playerAddress;
        uint256 balance;
        State state;
    }
    
    event ClaimListAdded (
        uint256 indexed tokenId,
        address indexed player,
        uint256 indexed date,
        uint256 balance,
        State state
    );

    event ClaimListRemoved (
        uint256 indexed tokenId,
        address indexed player,
        uint256 indexed date,
        uint256 balance,
        State state
    );

    mapping(uint256 => TicketItem) private ticketItems;
    
    function searchPlayer(address searchPlayerAddress) private view returns (uint256)
    {
        uint256 rtnIndex = 0;

        uint total = _ticketItemCounter.current();
        for (uint i = 1; i <= total; i++) {
            if (ticketItems[i].playerAddress == searchPlayerAddress) {
                rtnIndex = i;
            }
        }
        return rtnIndex;
    }

    function addClaimList(address playerAddress, uint256 tokenId, uint256 amount) external onlyOwner 
    {
        bool findCount = false;
        TicketItem memory claimItem;
        uint256 _findIndex = searchPlayer(playerAddress);

        if(_findIndex > 0){
            claimItem = ticketItems[_findIndex];
            if(claimItem.tokenId == tokenId){
                findCount = true;
            }
            else {
                delete claimItem;
            }
        }
        

        if(findCount){
            claimItem.balance = amount;
        }
        else {
            _ticketItemCounter.increment();
            uint id = _ticketItemCounter.current();

            ticketItems[id] = TicketItem(
                tokenId,
                playerAddress,
                amount,
                State.AddClaimList
            );

            emit ClaimListAdded(tokenId, playerAddress, block.timestamp, amount, State.AddClaimList);
        }
        

    }

    function getUnClaimByAddress() public view returns (TicketItem[] memory) {
        uint itemCount = 0;
        uint total = _ticketItemCounter.current();
        for (uint i = 1; i <= total; i++) {
            if (ticketItems[i].playerAddress == msg.sender) {
                itemCount ++;
            }
        }

        uint index = 0;
        TicketItem[] memory items = new TicketItem[](itemCount);
        for (uint i = 1; i <= total; i++) {
            if (ticketItems[i].playerAddress == msg.sender) {
                items[index] = ticketItems[i];
                index ++;
            }
        }
        return items;
    }

    function removeClaimList() public {
        require(searchPlayer(msg.sender) > 0, "There are no items to claim for the account.");
        
        uint total = _ticketItemCounter.current();

        for (uint i = 1; i <= total; i++) {
            if (ticketItems[i].playerAddress == msg.sender) {
                _mint(msg.sender, ticketItems[i].tokenId, ticketItems[i].balance, "");
                emit ClaimListRemoved(ticketItems[i].tokenId, msg.sender, block.timestamp, ticketItems[i].balance, State.RemoveClaimList);
                delete ticketItems[i];
            }
        }
         
    }

    function prevTransfer(address[] memory playerAddress, uint256 tokenId, uint256 amount) external onlyOwner {
        
        for(uint i = 0; i < playerAddress.length; i++)
        {
            _mint(playerAddress[i], tokenId, amount, "");
            emit ClaimListRemoved(tokenId, playerAddress[i], block.timestamp, amount, State.RemoveClaimList);
        }
        
    }
}