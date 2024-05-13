// contracts/Workshop/DigardWorkshop.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "../ERC1155/token/IDigardERC1155.sol";
import "../Utils/RandomNumber.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DigardWorkshop is Ownable {
    using Counters for Counters.Counter;
    using Randomize for Randomize.Random;

    Counters.Counter private _workshopGroupCounter;
    Counters.Counter private _workshopItemCounter;
    Randomize.Random private _randomize;
    address payable public workshopOwnerPool;
    uint levelSize = 10;

    struct RequiredItem {
        uint256 tokenId;
        address nftContract;
        uint256 amount;
        uint256 failedBurningAmount;
    }

    struct WorkshopItem {
        uint256 workshopGroupId;
        uint256 workshopItemId;
        uint256 tokenId;
        address nftContract;
        uint256 upgradePrice;
        address spendingContract;
        uint256 upgradeChanceRatio;
        uint256 totalRequiredItem;
        mapping(uint256 => RequiredItem) requiredItems;
    }

    struct WorkshopItemView {
        uint256 workshopGroupId;
        uint256 workshopItemId;
        uint256 tokenId;
        address nftContract;
        uint256 upgradePrice;
        address spendingContract;
        uint256 upgradeChanceRatio;
        uint256 totalRequiredItem;
        RequiredItem[] requiredItems;
    }

    event WorkshopItemUpgrade(
        uint256 indexed workshopItemId,
        uint256 indexed tokenId,
        address nftContract,
        uint256 upgradePrice,
        address spendingContract,
        uint256 upgradeChanceRatio,
        uint256 totalRequiredItem,
        uint256 randomizeChance,
        address processAddress,
        bool isUpgrade
    );

    mapping(uint256 => WorkshopItem) WorkshopItems;

    constructor() {
        workshopOwnerPool = payable(msg.sender);
    }

    function SetWorkshopPoolOwner(address _poolowner) public onlyOwner {
        workshopOwnerPool = payable(_poolowner);
    }

    function SetLevelSize(uint _levelSize) public onlyOwner {
        levelSize = _levelSize;
    }

    function SetWorkshopItem(
        uint256 workshopGroupId,
        uint256 workshopItemId,
        uint256 tokenId,
        address nftContract,
        uint256 upgradePrice,
        address spendingContract,
        uint256 upgradeChanceRatio,
        uint256 totalRequiredItem,
        RequiredItem[] memory requiredItems
    ) public onlyOwner {
        require(WorkshopItems[workshopItemId].workshopItemId == 0, "Workshop item avaible");
        _workshopItemCounter.increment();
        uint256 index = _workshopItemCounter.current();
        WorkshopItem storage item = WorkshopItems[index];
        item.workshopGroupId = workshopGroupId;
        item.workshopItemId = workshopItemId;
        item.nftContract = nftContract;
        item.spendingContract = spendingContract;
        item.tokenId = tokenId;
        item.totalRequiredItem = totalRequiredItem;
        item.upgradeChanceRatio = upgradeChanceRatio;
        item.upgradePrice = upgradePrice;
        for (uint256 i = 0; i < totalRequiredItem; i++) {
            item.requiredItems[i] = requiredItems[i];
        }
        
    }
    
    function UpgradeItem(uint256 workshopItemId)
        public
        payable
        returns (bool)
    {
        uint index = findWorkshopItemIndex(workshopItemId);
        require(index > 0, "The item to be upgraded could not be found.");
        WorkshopItem storage workshopItem = WorkshopItems[index];
        
        require(
            IERC20(workshopItem.spendingContract).balanceOf(msg.sender) >= workshopItem.upgradePrice,
            "Insufficient token balance required for upgrade."
        );
        require(
            IERC20(workshopItem.spendingContract).allowance(msg.sender, address(this)) >= workshopItem.upgradePrice,
            "Allow for the amount of tokens required for the upgrade."
        );

        uint256 randomizeNumber = _randomize.newRandomNumber();
        bool isUpgrade = randomizeNumber < workshopItem.upgradeChanceRatio;

        for (uint256 i = 0; i < workshopItem.totalRequiredItem; i++) {
            require(
                IERC1155(workshopItem.requiredItems[i].nftContract).balanceOf(
                    msg.sender,
                    workshopItem.requiredItems[i].tokenId
                ) >= workshopItem.requiredItems[i].amount,
                "Insufficient nft balance required for upgrade"
            );
            require(
                IERC1155(workshopItem.requiredItems[i].nftContract).isApprovedForAll(msg.sender, address(this)),
                "Allow for the amount of nft required for the upgrade."
            );
            
            if (isUpgrade) {
                IDigardERC1155(workshopItem.requiredItems[i].nftContract)
                    .burnItem(
                        msg.sender,
                        workshopItem.requiredItems[i].tokenId,
                        workshopItem.requiredItems[i].amount
                    );
            } else {
                IDigardERC1155(workshopItem.requiredItems[i].nftContract)
                    .burnItem(
                        msg.sender,
                        workshopItem.requiredItems[i].tokenId,
                        workshopItem.requiredItems[i].failedBurningAmount
                    );
            }
        }

        if (isUpgrade) {
            IDigardERC1155(workshopItem.nftContract).mintItem(
                msg.sender, workshopItem.tokenId, 1
            );
        }

        IERC20(workshopItem.spendingContract).transferFrom(
            msg.sender,
            workshopOwnerPool,
            workshopItem.upgradePrice
        );

        emit WorkshopItemUpgrade(
            workshopItemId,
            WorkshopItems[index].tokenId,
            WorkshopItems[index].nftContract,
            WorkshopItems[index].upgradePrice,
            WorkshopItems[index].spendingContract,
            WorkshopItems[index].upgradeChanceRatio,
            WorkshopItems[index].totalRequiredItem,
            randomizeNumber,
            msg.sender,
            isUpgrade
        );

        return isUpgrade;
    }

    function findWorkshopItemIndex(uint256 workshopItemId) internal
        view
        onlyOwner
        returns (uint)
    {
        uint256 total = _workshopItemCounter.current();
        uint rtnWorkshopItem = 0;
        for (uint256 i = 1; i <= total; i++) {
            if(WorkshopItems[i].workshopItemId == workshopItemId){
                rtnWorkshopItem = i;
                break;
            }
        }
        return rtnWorkshopItem;
    }

    function fetchWorkshopItem(uint256 workshopGroupId)
        public
        view
        onlyOwner
        returns (WorkshopItemView[] memory)
    {
        uint256 total = _workshopItemCounter.current();
        uint256 index = 0;
        uint256 viewLength = levelSize-1;
        WorkshopItemView[] memory workshopItemViews = new WorkshopItemView[](viewLength);
        for (uint256 i = 1; i <= total; i++) 
        {
            if (WorkshopItems[i].workshopGroupId == workshopGroupId) 
            {
                RequiredItem[] memory requiredItems = new RequiredItem[](WorkshopItems[i].totalRequiredItem);
                for (uint256 t = 0; t < WorkshopItems[i].totalRequiredItem; t++) {
                    requiredItems[t] = WorkshopItems[i].requiredItems[t];
                }
                workshopItemViews[index] = WorkshopItemView(
                    WorkshopItems[i].workshopGroupId,
                    WorkshopItems[i].workshopItemId,
                    WorkshopItems[i].tokenId,
                    WorkshopItems[i].nftContract,
                    WorkshopItems[i].upgradePrice,
                    WorkshopItems[i].spendingContract,
                    WorkshopItems[i].upgradeChanceRatio,
                    WorkshopItems[i].totalRequiredItem,
                    requiredItems
                );
                index++;
            }
        }

        return workshopItemViews;
    }

}
