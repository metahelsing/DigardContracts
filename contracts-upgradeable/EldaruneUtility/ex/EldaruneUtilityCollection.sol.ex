// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "../Utils/RandomNumber.sol";
import "./interfaces/IEldaruneUtilityBox.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "../Interfaces/IDigardERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../Utils/CountersUpgradeable.sol";

contract EldaruneUtilityCollection is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    using Randomize for Randomize.Random;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using StringsUpgradeable for uint256;

    struct OpenBoxProgram {
        uint64 startDate;
        bool openBoxEnabled;
    }

    struct UtilityItem {
        uint itemId;
        uint256 tokenId;
        uint itemLevel;
        uint chancePercent;
        uint256 upgradeFee;
    }

    struct WhiteListChanceMultiplier {
        uint256 tokenId;
        uint chanceRateIncreaseMultiplier;
    }

    event OpenBoxProgramEvent(
        uint64 startDate,
        bool openBoxEnabled
    );

    event NftMintEvent(
        uint256 tokenId,
        address indexed mintedAddress,
        uint indexed itemLevel,
        uint chancePercent
    );

    event NftUpgradeEvent(
        uint256 indexed prevTokenId,
        address indexed mintedAddress,
        uint prevItemLevel,
        uint256 indexed upgradeTokenId,
        uint upgradeItemLevel
    );

    Randomize.Random private _randomize;
    CountersUpgradeable.Counter private __utilityItemCounter;
    address payable _mintOwner;
    address _eldaruneUtilityBoxAddress;
    OpenBoxProgram private _openBoxProgram;
    mapping(address => uint256) _mintedAddressList;
    mapping(uint => UtilityItem) _utilityItems;
    mapping(address => WhiteListChanceMultiplier[]) _whiteListChanceMultipliers;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        OpenBoxProgram memory __openBoxProgram,
        UtilityItem[] memory __utilityItems,
        address __eldaruneUtilityBoxAddress
    ) public initializer {
       
        __Ownable_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        _eldaruneUtilityBoxAddress = __eldaruneUtilityBoxAddress;
        _mintOwner = payable(msg.sender);
        _openBoxProgram = __openBoxProgram;

        for (uint i = 0; i < __utilityItems.length; i++) {
            __utilityItemCounter.increment();
            uint index = __utilityItemCounter.current();
            _utilityItems[index] = UtilityItem(
                index,
                __utilityItems[i].tokenId,
                __utilityItems[i].itemLevel,
                __utilityItems[i].chancePercent,
                __utilityItems[i].upgradeFee
            );
        }
    }

    function uri(uint256 tokenId) public pure override returns (string memory) {
        return string.concat("https://cdn.digard.io/Eldarune/UtilityCollection/", tokenId.toString(), ".json");
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function updateOpenBoxProgram(
        OpenBoxProgram memory __openBoxProgramProgram
    ) public onlyOwner {
        _openBoxProgram = __openBoxProgramProgram;
        emit OpenBoxProgramEvent(
            __openBoxProgramProgram.startDate,
            __openBoxProgramProgram.openBoxEnabled
        );
    }

    function saveUtilityItems(
        UtilityItem[] memory __utilityItems
    ) public onlyOwner {
    
        require(__utilityItems.length > 0, "__utilityItems array is empty");
        for (uint i = 0; i < __utilityItems.length; i++) {
            uint index = _utilityItems[__utilityItems[i].itemId].itemId;
            if (index == 0) {
                __utilityItemCounter.increment();
                index = __utilityItemCounter.current();
            }
            _utilityItems[index] = UtilityItem(
                index,
                __utilityItems[i].tokenId,
                __utilityItems[i].itemLevel,
                __utilityItems[i].chancePercent,
                __utilityItems[i].upgradeFee
            );
        }
    }

    function setMintOwner(address payable __mintOwner) public onlyOwner {
        require(_msgSender() != address(0x0), "Public address is not correct");
        _mintOwner = __mintOwner;
    }

    function setWhiteListChanceMultiplier(
        address __whiteListAddress,
        WhiteListChanceMultiplier[] memory __whiteListChanceMultiplier
    ) public onlyOwner {
        require(
            __whiteListChanceMultiplier.length > 0,
            "whiteListChanceMultiplier array is empty"
        );
        for (uint i = 0; i < __whiteListChanceMultiplier.length; i++) {
            if (_whiteListChanceMultipliers[__whiteListAddress].length > 0) {
                for (
                    uint k = 0;
                    k < _whiteListChanceMultipliers[__whiteListAddress].length;
                    i++
                ) {
                    require(_whiteListChanceMultipliers[__whiteListAddress][k].chanceRateIncreaseMultiplier > 0 && _whiteListChanceMultipliers[__whiteListAddress][k].chanceRateIncreaseMultiplier <= 4, "chanceRateIncreaseMultiplier range out [1,4]");
                    if (
                        _whiteListChanceMultipliers[__whiteListAddress][k]
                            .tokenId == __whiteListChanceMultiplier[i].tokenId
                    ) {
                        _whiteListChanceMultipliers[__whiteListAddress][k]
                            .chanceRateIncreaseMultiplier = __whiteListChanceMultiplier[
                            i
                        ].chanceRateIncreaseMultiplier;
                    } else {
                        _whiteListChanceMultipliers[__whiteListAddress].push(
                            WhiteListChanceMultiplier(
                                __whiteListChanceMultiplier[i].tokenId,
                                __whiteListChanceMultiplier[i]
                                    .chanceRateIncreaseMultiplier
                            )
                        );
                    }
                }
            } else {
                _whiteListChanceMultipliers[__whiteListAddress].push(
                    WhiteListChanceMultiplier(
                        __whiteListChanceMultiplier[i].tokenId,
                        __whiteListChanceMultiplier[i]
                            .chanceRateIncreaseMultiplier
                    )
                );
            }
        }
    }

    function unBoxing(uint256 tokenId) public nonReentrant whenNotPaused {
        address nftMinter = _msgSender();
        address ownerOfNft = IEldaruneUtilityBox(_eldaruneUtilityBoxAddress).ownerOf(tokenId);
        require(ownerOfNft == nftMinter, "You need to have Eldarune Utility Box to open it"); 
        require(_openBoxProgram.openBoxEnabled, "Unboxing is inactive");
        require(_openBoxProgram.startDate <= block.timestamp, "Unboxing has not yet started");
        require(nftMinter != address(0x0), "Public address is not correct");
        
        uint256 randomNumber = _randomize.newNonZeroRandomNumber();
        uint256 utilityItemTotal = __utilityItemCounter.current();
        UtilityItem memory _utilityItem;
        WhiteListChanceMultiplier[] memory _chanceMultipliersByAddress = _whiteListChanceMultipliers[nftMinter];
        for (uint i = 1; i <= utilityItemTotal; i++) {
            uint chancePercent = _utilityItems[i].chancePercent;
            if (_chanceMultipliersByAddress.length > 0) {
                for (uint k = 0; k <= _chanceMultipliersByAddress.length; k++) {
                    if (
                        _chanceMultipliersByAddress[k].tokenId ==
                        _utilityItems[i].tokenId
                    ) {
                        chancePercent = chancePercent * _chanceMultipliersByAddress[k].chanceRateIncreaseMultiplier;
                    }
                }
            }
            if (chancePercent >= randomNumber) {
                _utilityItem = _utilityItems[i];
            }
        }
        IEldaruneUtilityBox(_eldaruneUtilityBoxAddress).burnForUpgrade(tokenId);
       
        _mint(nftMinter, _utilityItem.tokenId, 1, "");

        emit NftMintEvent(
            _utilityItem.tokenId,
            nftMinter,
            _utilityItem.itemLevel,
            _utilityItem.chancePercent
        );
    }

     function upgradeNFT(
        uint256 tokenId
    ) public payable nonReentrant whenNotPaused {
        require(
            findUtilityItem(tokenId).tokenId == tokenId,
            "Undefined token id"
        );
        UtilityItem memory _utilityItem = findUtilityItem(tokenId);
        uint nextIndex = _utilityItem.itemId + 1;
        UtilityItem memory _nextUtilityItem = _utilityItems[nextIndex];
        require(
            _nextUtilityItem.itemId >= 0,
            "The maximum level to be upgraded has been reached"
        );
        require(
            _nextUtilityItem.upgradeFee == msg.value,
            "Not enough funds for upgrade"
        );
        uint256 requirementTime = addDays(_openBoxProgram.startDate, 1);
        uint256 requirementBalance = 1;
        if (requirementTime > block.timestamp) {
            requirementBalance = 2;
        }
        require(
            balanceOf(_msgSender(), tokenId) >= requirementBalance,
            "Ownership of the nft is required for the upgrade"
        );
        
        _burn(_msgSender(), tokenId, requirementBalance);
        _mint(_msgSender(), _nextUtilityItem.tokenId, 1, "");
        _mintOwner.transfer(msg.value);

        emit NftUpgradeEvent(
            _utilityItem.tokenId,
            _msgSender(),
            _utilityItem.itemLevel,
            _nextUtilityItem.tokenId,
            _nextUtilityItem.itemLevel
        );
    }

    function addDays(
        uint256 timestamp,
        uint256 daysToAdd
    ) private pure returns (uint256) {
        return timestamp + (daysToAdd * 1 days);
    }

    function findUtilityItem(
        uint256 tokenId
    ) private view returns (UtilityItem memory) {
        UtilityItem memory _utilityItem;
        uint256 lastUtilityIndex = __utilityItemCounter.current();
        for (uint i = 1; i <= lastUtilityIndex; i++) {
            if (_utilityItems[i].tokenId == tokenId) {
                _utilityItem = _utilityItems[i];
            }
        }
        return _utilityItem;
    }

    
}

