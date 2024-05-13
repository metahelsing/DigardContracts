// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../Utils/RandomNumber.sol";
import "../Interfaces/IDigardERC1155Burnable.sol";
import "../Interfaces/IDigardERC1155Mintable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";
import "hardhat/console.sol";

contract EldaruneChest is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    address _eldaruneGameCollectionAddress;
    using Randomize for Randomize.Random;
    Randomize.Random private _randomize;

    enum Rarity {
        Empty,
        Common,
        Uncommon,
        Rare,
        Epic,
        Legendary
    }

    struct Chest {
        address chestCollectionAddress;
        uint256 tokenId;
        ChestItem[] chestItems;
    }

    struct ChestItem {
        address collectionAddress;
        uint256 chestItemId;
        uint256 minChance;
        uint256 maxChance;
        uint256[] tokenIds;
        Rarity rarity;
    }

    struct Package {
        address packageCollectionAddress;
        uint256 tokenId;
        PackageItem[] packageItems;
    }

    struct PackageItem {
        uint256 tokenId;
        uint256 amount;
        uint256 maxOwnedAmount;
        address collectionAddress;
    }

    event SaveChest(
        address chestCollectionAddress,
        uint256 tokenId,
        ChestItem[] chestItems,
        address executedAddress
    );

    event ChestOpen(
        address indexed ownerAddress,
        string tokenUri,
        uint256 chestTokenId,
        uint256 winTokenId,
        uint256 dropChange
    );

    event SavePackage(
        address packageCollectionAddress,
        uint256 tokenId,
        PackageItem[] packageItems,
        address executedAddress
    );

    event PackageOpen(
        uint256 indexed packageTokenId,
        uint256 indexed tokenId,
        address indexed ownerAddress,
        string tokenUri,
        uint256 tokenAmount
    );

    event PackageOpenWithAmount(
        uint256 indexed packageTokenId,
        uint256 indexed tokenId,
        address indexed ownerAddress,
        string tokenUri,
        uint256 tokenAmount
    );

    mapping(uint256 => Chest) _chests;
    mapping(uint256 => Package) _packages;

    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
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

    function saveChests(
        Chest[] memory __chests
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(__chests.length > 0, "No chest item");
        for (uint256 i = 0; i < __chests.length; i++) {
            Chest memory chestItem = __chests[i];
            _chests[chestItem.tokenId].chestCollectionAddress = chestItem
                .chestCollectionAddress;
            _chests[chestItem.tokenId].tokenId = chestItem.tokenId;
            delete _chests[chestItem.tokenId].chestItems;
            console.log("__index", chestItem.chestItems.length);
            for (uint256 k = 0; k < chestItem.chestItems.length; k++) {
                _chests[chestItem.tokenId].chestItems.push(
                    chestItem.chestItems[k]
                );
            }
            emit SaveChest(
                chestItem.chestCollectionAddress,
                chestItem.tokenId,
                chestItem.chestItems,
                _msgSender()
            );
        }
    }

    function savePackages(
        Package[] memory __packages
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(__packages.length > 0, "No chest item");
        for (uint256 i = 0; i < __packages.length; i++) {
            Package memory packageItem = __packages[i];
            _packages[packageItem.tokenId]
                .packageCollectionAddress = __packages[i]
                .packageCollectionAddress;
            _packages[packageItem.tokenId].tokenId = packageItem.tokenId;
            delete _packages[packageItem.tokenId].packageItems;
            for (uint256 k = 0; k < __packages[i].packageItems.length; k++) {
                _packages[packageItem.tokenId].packageItems.push(
                    packageItem.packageItems[k]
                );
            }
            emit SavePackage(
                packageItem.packageCollectionAddress,
                packageItem.tokenId,
                packageItem.packageItems,
                _msgSender()
            );
        }
    }

    function openChest(uint256 tokenId) public nonReentrant whenNotPaused {
        require(_chests[tokenId].tokenId > 0, "Could not find chest to open");
        require(
            IERC1155Upgradeable(_chests[tokenId].chestCollectionAddress)
                .balanceOf(_msgSender(), tokenId) > 0,
            "You must own a chest to open a chest"
        );

        uint256 randomNumber = _randomize.newNonZeroRandomNumber(1000);
        uint256 winTokenId;
        address collectionAddress;
        for (uint i = 0; i < _chests[tokenId].chestItems.length; i++) {
            if (
                randomNumber >= _chests[tokenId].chestItems[i].minChance &&
                randomNumber <= _chests[tokenId].chestItems[i].maxChance
            ) {
                uint256 chracterIndex = _randomize.newRandomNumber(
                    _chests[tokenId].chestItems[i].tokenIds.length
                );
                winTokenId = _chests[tokenId].chestItems[i].tokenIds[
                    chracterIndex
                ];
                collectionAddress = _chests[tokenId]
                    .chestItems[i]
                    .collectionAddress;
                break;
            }
        }

        IDigardERC1155Mintable(collectionAddress).mint(
            _msgSender(),
            winTokenId,
            1,
            "0x"
        );
        IDigardERC1155Burnable(_chests[tokenId].chestCollectionAddress).burn(
            _msgSender(),
            tokenId,
            1
        );
        string memory tokenUri = IERC1155MetadataURIUpgradeable(
            collectionAddress
        ).uri(winTokenId);

        emit ChestOpen(
            _msgSender(),
            tokenUri,
            tokenId,
            winTokenId,
            randomNumber
        );
    }

    function openAllChest(uint256 tokenId) public nonReentrant whenNotPaused {
        require(_chests[tokenId].tokenId > 0, "Could not find chest to open");
        uint256 balance = IERC1155Upgradeable(
            _chests[tokenId].chestCollectionAddress
        ).balanceOf(_msgSender(), tokenId);
        require(balance > 0, "You must own a chest to open a chest");
        for (uint256 k = 0; k < balance; k++) {
            uint256 randomNumber = _randomize.newNonZeroRandomNumber(1000);
            uint256 winTokenId;
            address collectionAddress;
            for (uint i = 0; i < _chests[tokenId].chestItems.length; i++) {
                if (
                    randomNumber >= _chests[tokenId].chestItems[i].minChance &&
                    randomNumber <= _chests[tokenId].chestItems[i].maxChance
                ) {
                    uint256 chracterIndex = _randomize.newRandomNumber(
                        _chests[tokenId].chestItems[i].tokenIds.length
                    );

                    winTokenId = _chests[tokenId].chestItems[i].tokenIds[
                        chracterIndex
                    ];
                    collectionAddress = _chests[tokenId]
                        .chestItems[i]
                        .collectionAddress;
                    break;
                }
            }

            IDigardERC1155Mintable(collectionAddress).mint(
                _msgSender(),
                winTokenId,
                1,
                "0x"
            );
            IDigardERC1155Burnable(_chests[tokenId].chestCollectionAddress)
                .burn(_msgSender(), tokenId, 1);
            string memory tokenUri = IERC1155MetadataURIUpgradeable(
                collectionAddress
            ).uri(winTokenId);

            emit ChestOpen(
                _msgSender(),
                tokenUri,
                tokenId,
                winTokenId,
                randomNumber
            );
        }
    }

    function getChest(uint256 tokenId) public view returns (Chest memory) {
        return _chests[tokenId];
    }

    function openPackage(uint256 tokenId) public nonReentrant whenNotPaused {
        require(_packages[tokenId].tokenId > 0, "Could not find chest to open");
        Package memory package = _packages[tokenId];
        require(
            IERC1155Upgradeable(package.packageCollectionAddress).balanceOf(
                _msgSender(),
                tokenId
            ) > 0,
            "You must own a package to open a package"
        );
        for (uint i = 0; i < package.packageItems.length; i++) {
            bool mintableFlag = true;
            PackageItem memory packageItem = package.packageItems[i];
            if (packageItem.maxOwnedAmount > 0) {
                uint256 ownedAmount = IERC1155Upgradeable(
                    packageItem.collectionAddress
                ).balanceOf(_msgSender(), packageItem.tokenId);
                if (ownedAmount >= packageItem.maxOwnedAmount) {
                    mintableFlag = false;
                }
            }

            if (mintableFlag) {
                IDigardERC1155Mintable(packageItem.collectionAddress).mint(
                    _msgSender(),
                    packageItem.tokenId,
                    packageItem.amount,
                    msg.data
                );
                string memory tokenUri = IERC1155MetadataURIUpgradeable(
                    packageItem.collectionAddress
                ).uri(packageItem.tokenId);
                emit PackageOpen(
                    tokenId,
                    packageItem.tokenId,
                    _msgSender(),
                    tokenUri,
                    packageItem.amount
                );
                emit PackageOpenWithAmount(
                    tokenId,
                    packageItem.tokenId,
                    _msgSender(),
                    tokenUri,
                    packageItem.amount
                );
            }
        }

        IDigardERC1155Burnable(_packages[tokenId].packageCollectionAddress)
            .burn(_msgSender(), tokenId, 1);
    }

    function gRole() public {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}
