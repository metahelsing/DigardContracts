// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../Utils/RandomNumber.sol";
import "../Interfaces/IDigardERC1155Burnable.sol";
import "../Interfaces/IDigardERC1155Mintable.sol";
import "../Interfaces/IDigardERC1155Name.sol";
import "../Interfaces/IDigardERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";

contract DigardWorkshop is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    using Randomize for Randomize.Random;

    Randomize.Random private _randomize;
    address payable public _workshopOwnerPool;

    struct WorkshopGroup {
        uint256 workshopGroupId;
        bool disableChanceRatio;
    }

    struct WorkshopItem {
        uint256 workshopGroupId;
        uint256 workshopItemId;
        uint256 tokenId;
        uint256 level;
        uint256 upgradePrice;
        uint256 upgradeChanceRatio;
        uint256 totalRequiredItem;
        address nftContract;
        address spendingContract;
        RequiredItem[] requiredItems;
    }

    struct RequiredItem {
        uint256 tokenId;
        address nftContract;
        uint256 amount;
        uint256 failedBurningAmount;
    }

    struct BoostChanceItem {
        uint256 tokenId;
        uint256 boostChance;
        address tokenAddress;
    }

    event WorkshopGroupSave(uint256 workshopGroupId, bool disableChanceRatio);

    event BoostChanceItemSave(
        uint256 workshopGroupId,
        BoostChanceItem[] boostChangeItems
    );

    event WorkshopItemSave(
        uint256 workshopGroupId,
        uint256 workshopItemId,
        uint256 tokenId,
        uint256 level,
        uint256 upgradePrice,
        uint256 upgradeChanceRatio,
        uint256 totalRequiredItem,
        address nftContract,
        address spendingContract,
        RequiredItem[] requiredItems,
        string tokenUri,
        string collectionName
    );

    event WorkshopItemUpgrade(
        uint256 indexed workshopGroupId,
        uint256 indexed workshopItemId,
        address indexed owner,
        bool isUpgrade,
        uint256 spendingAmount
    );

    event WorkshopItemBoostUpgrade(
        uint256 indexed workshopGroupId,
        uint256 indexed workshopItemId,
        uint256 spendingAmount,
        uint256 boostTokenId,
        uint256 boostedTotalChance,
        address indexed owner,
        bool isUpgrade
    );

    event UpgradeResult(bool isUpgrade, uint256 randomNumber);

    mapping(uint256 => WorkshopGroup) _workshopGroups;

    mapping(uint256 => WorkshopItem) _workshopItems;

    mapping(uint256 => mapping(uint256 => BoostChanceItem)) _boostChanceItems;

    constructor() {}

    function initialize(address __workshopOwnerPool) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        _workshopOwnerPool = payable(__workshopOwnerPool);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function setWorkshopPoolOwner(
        address __workshopOwnerPool
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _workshopOwnerPool = payable(__workshopOwnerPool);
    }

    function saveWorkshopGroupItem(
        WorkshopGroup[] memory __workshopGroups
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(__workshopGroups.length > 0, "Workshop group not found");
        for (uint256 i = 0; i < __workshopGroups.length; i++) {
            uint256 index = __workshopGroups[i].workshopGroupId;
            _workshopGroups[index] = WorkshopGroup(
                __workshopGroups[i].workshopGroupId,
                __workshopGroups[i].disableChanceRatio
            );

            emit WorkshopGroupSave(
                __workshopGroups[i].workshopGroupId,
                __workshopGroups[i].disableChanceRatio
            );
        }
    }

    function saveWorkshopItem(
        WorkshopItem[] memory __workshopItems
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(__workshopItems.length > 0, "Workshop items not found");
        for (uint256 i = 0; i < __workshopItems.length; i++) {
            uint256 index = __workshopItems[i].workshopItemId;
            uint256 _decimal = IERC20MetadataUpgradeable(
                __workshopItems[i].spendingContract
            ).decimals();
            _decimal = 10 ** uint256(_decimal);
            __workshopItems[i].upgradePrice =
                __workshopItems[i].upgradePrice *
                _decimal;
            delete _workshopItems[index];
            for (
                uint256 k = 0;
                k < __workshopItems[i].requiredItems.length;
                k++
            ) {
                _workshopItems[index].requiredItems.push(
                    __workshopItems[i].requiredItems[k]
                );
            }
            _workshopItems[index].workshopGroupId = __workshopItems[i]
                .workshopGroupId;
            _workshopItems[index].workshopItemId = index;
            _workshopItems[index].tokenId = __workshopItems[i].tokenId;
            _workshopItems[index].level = __workshopItems[i].level;
            _workshopItems[index].upgradePrice = __workshopItems[i]
                .upgradePrice;
            _workshopItems[index].upgradeChanceRatio = __workshopItems[i]
                .upgradeChanceRatio;
            _workshopItems[index].totalRequiredItem = __workshopItems[i]
                .totalRequiredItem;
            _workshopItems[index].nftContract = __workshopItems[i].nftContract;
            _workshopItems[index].spendingContract = __workshopItems[i]
                .spendingContract;

            string memory tokenUri = IERC1155MetadataURIUpgradeable(
                _workshopItems[index].nftContract
            ).uri(_workshopItems[index].tokenId);

            string memory collectionName = IDigardERC1155Name(
                _workshopItems[index].nftContract
            ).name();

            emit WorkshopItemSave(
                _workshopItems[index].workshopGroupId,
                _workshopItems[index].workshopItemId,
                _workshopItems[index].tokenId,
                _workshopItems[index].level,
                _workshopItems[index].upgradePrice,
                _workshopItems[index].upgradeChanceRatio,
                _workshopItems[index].totalRequiredItem,
                _workshopItems[index].nftContract,
                _workshopItems[index].spendingContract,
                _workshopItems[index].requiredItems,
                tokenUri,
                collectionName
            );
        }
    }

    function saveBoostChanceItem(
        uint256[] memory workshopGroupIds,
        BoostChanceItem[] memory boostChanceItems
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(workshopGroupIds.length > 0, "Workshopgroup ids not found");
        require(boostChanceItems.length > 0, "Boost change items not found");
        for (uint256 k = 0; k < workshopGroupIds.length; k++) {
            uint256 workshopGroupId = workshopGroupIds[k];
            for (uint256 i = 0; i < boostChanceItems.length; i++) {
                uint256 tokenId = boostChanceItems[i].tokenId;
                _boostChanceItems[workshopGroupId][tokenId] = boostChanceItems[
                    i
                ];
            }
            emit BoostChanceItemSave(workshopGroupId, boostChanceItems);
        }
    }

    function _upgradeItem(
        WorkshopItem memory workshopItem,
        uint256 chanceRatio
    ) private returns (bool) {
        bool isUpgrade;

        if (_workshopGroups[workshopItem.workshopGroupId].disableChanceRatio) {
            isUpgrade = true;
        } else {
            uint256 randomizeNumber = _randomize.newNonZeroRandomNumber(100);
            isUpgrade = randomizeNumber < chanceRatio;
        }

        for (uint256 i = 0; i < workshopItem.requiredItems.length; i++) {
            require(
                IERC1155Upgradeable(workshopItem.requiredItems[i].nftContract)
                    .balanceOf(
                        _msgSender(),
                        workshopItem.requiredItems[i].tokenId
                    ) >= workshopItem.requiredItems[i].amount,
                "Insufficient nft balance required for upgrade"
            );

            if (isUpgrade) {
                IDigardERC1155Burnable(
                    workshopItem.requiredItems[i].nftContract
                ).burn(
                        _msgSender(),
                        workshopItem.requiredItems[i].tokenId,
                        workshopItem.requiredItems[i].amount
                    );
            } else {
                IDigardERC1155Burnable(
                    workshopItem.requiredItems[i].nftContract
                ).burn(
                        _msgSender(),
                        workshopItem.requiredItems[i].tokenId,
                        workshopItem.requiredItems[i].failedBurningAmount
                    );
            }
        }

        if (isUpgrade) {
            IDigardERC1155Mintable(workshopItem.nftContract).mint(
                _msgSender(),
                workshopItem.tokenId,
                1,
                "0x0"
            );
        }

        IERC20Upgradeable(workshopItem.spendingContract).transferFrom(
            _msgSender(),
            _workshopOwnerPool,
            workshopItem.upgradePrice
        );

        return isUpgrade;
    }

    function upgradeItem(
        uint256 workshopItemId
    ) public nonReentrant whenNotPaused {
        require(
            _workshopItems[workshopItemId].workshopItemId > 0,
            "The item to be upgraded could not be found."
        );
        WorkshopItem memory workshopItem = _workshopItems[workshopItemId];

        require(
            IERC20Upgradeable(workshopItem.spendingContract).balanceOf(
                _msgSender()
            ) >= workshopItem.upgradePrice,
            "Insufficient token balance required for upgrade."
        );

        bool isUpgrade = _upgradeItem(
            workshopItem,
            workshopItem.upgradeChanceRatio
        );

        emit WorkshopItemUpgrade(
            workshopItem.workshopGroupId,
            workshopItem.workshopItemId,
            _msgSender(),
            isUpgrade,
            workshopItem.upgradePrice
        );
    }

    function upgradeBatchItem(
        uint256 workshopItemId
    ) public nonReentrant whenNotPaused {
        require(
            _workshopItems[workshopItemId].workshopItemId > 0,
            "The item to be upgraded could not be found."
        );

        WorkshopItem memory workshopItem = _workshopItems[workshopItemId];

        uint256 tokenBalance = IERC1155Upgradeable(
            workshopItem.requiredItems[0].nftContract
        ).balanceOf(_msgSender(), workshopItem.requiredItems[0].tokenId);

        uint256 upgradeLength = tokenBalance /
            workshopItem.requiredItems[0].amount;

        require(
            upgradeLength > 0,
            "Insufficient nft balance required for upgrade"
        );
        uint256 spendingMultiplier = 2;

        uint256 totalBalance = workshopItem.upgradePrice * spendingMultiplier;

        require(
            IERC20Upgradeable(workshopItem.spendingContract).balanceOf(
                _msgSender()
            ) >= totalBalance,
            "Insufficient token balance required for upgrade."
        );

        for (uint256 i = 0; i < upgradeLength; ) {
            bool isUpgrade = _upgradeItem(
                workshopItem,
                workshopItem.upgradeChanceRatio
            );
            emit WorkshopItemUpgrade(
                workshopItem.workshopGroupId,
                workshopItem.workshopItemId,
                _msgSender(),
                isUpgrade,
                workshopItem.upgradePrice * spendingMultiplier
            );
            unchecked {
                i++;
            }
        }
    }

    function upgradeBoostItem(
        uint256 workshopItemId,
        uint256 boostTokenId
    ) public nonReentrant whenNotPaused {
        require(
            _workshopItems[workshopItemId].workshopItemId > 0,
            "The item to be upgraded could not be found."
        );
        WorkshopItem memory workshopItem = _workshopItems[workshopItemId];

        require(
            IERC20Upgradeable(workshopItem.spendingContract).balanceOf(
                _msgSender()
            ) >= workshopItem.upgradePrice,
            "Insufficient token balance required for upgrade."
        );

        BoostChanceItem memory boostChanceItem = _boostChanceItems[
            workshopItem.workshopGroupId
        ][boostTokenId];

        require(boostChanceItem.tokenId > 0, "Undefined boost nft tokenId");
        require(
            IERC1155Upgradeable(boostChanceItem.tokenAddress).balanceOf(
                _msgSender(),
                boostChanceItem.tokenId
            ) >= 1,
            "Insufficient nft balance required for upgrade boost"
        );
        uint256 chance = workshopItem.upgradeChanceRatio +
            boostChanceItem.boostChance;
        if (chance > 100) chance = 100;

        bool isUpgrade = _upgradeItem(workshopItem, chance);

        IDigardERC1155Burnable(boostChanceItem.tokenAddress).burn(
            _msgSender(),
            boostChanceItem.tokenId,
            1
        );

        emit WorkshopItemBoostUpgrade(
            workshopItem.workshopGroupId,
            workshopItem.workshopItemId,
            workshopItem.upgradePrice,
            boostChanceItem.tokenId,
            chance,
            _msgSender(),
            isUpgrade
        );
    }

    function upgradeBoostBatchItem(
        uint256 workshopItemId,
        uint256 boostTokenId
    ) public nonReentrant whenNotPaused {
        require(
            _workshopItems[workshopItemId].workshopItemId > 0,
            "The item to be upgraded could not be found."
        );

        WorkshopItem memory workshopItem = _workshopItems[workshopItemId];

        uint256 tokenBalance = IERC1155Upgradeable(
            workshopItem.requiredItems[0].nftContract
        ).balanceOf(_msgSender(), workshopItem.requiredItems[0].tokenId);

        uint256 upgradeLength = tokenBalance /
            workshopItem.requiredItems[0].amount;

        require(
            upgradeLength > 0,
            "Insufficient nft balance required for upgrade"
        );
        uint256 spendingMultiplier = 2;

        uint256 totalBalance = workshopItem.upgradePrice * spendingMultiplier;

        require(
            IERC20Upgradeable(workshopItem.spendingContract).balanceOf(
                _msgSender()
            ) >= totalBalance,
            "Insufficient token balance required for upgrade."
        );

        BoostChanceItem memory boostChanceItem = _boostChanceItems[
            workshopItem.workshopGroupId
        ][boostTokenId];

        require(boostChanceItem.tokenId > 0, "Undefined boost nft tokenId");
        require(
            IERC1155Upgradeable(boostChanceItem.tokenAddress).balanceOf(
                _msgSender(),
                boostChanceItem.tokenId
            ) >= upgradeLength,
            "Insufficient nft balance required for upgrade boost"
        );
        uint256 chance = workshopItem.upgradeChanceRatio +
            boostChanceItem.boostChance;
        if (chance > 100) chance = 100;

        IDigardERC1155Burnable(boostChanceItem.tokenAddress).burn(
            _msgSender(),
            boostChanceItem.tokenId,
            upgradeLength
        );
        for (uint256 i = 0; i < upgradeLength; ) {
            bool isUpgrade = _upgradeItem(workshopItem, chance);

            emit WorkshopItemBoostUpgrade(
                workshopItem.workshopGroupId,
                workshopItem.workshopItemId,
                workshopItem.upgradePrice * spendingMultiplier,
                boostChanceItem.tokenId,
                chance,
                _msgSender(),
                isUpgrade
            );
            unchecked {
                i++;
            }
        }
    }

    function getWorkshopItem(
        uint256 workshopItemId
    ) public view returns (uint256) {
        return _workshopItems[workshopItemId].workshopItemId;
    }
}
