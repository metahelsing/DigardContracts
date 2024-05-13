// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "../Interfaces/IDigardERC1155Burnable.sol";
import "../Interfaces/IDigardERC1155Mintable.sol";
import "../Interfaces/IDigardERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract EldarunesTokenBoostCollection is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721PausableUpgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _commonNextTokenId;
    uint256 private _commonMaxTokenId;

    uint256 private _unCommonNextTokenId;
    uint256 private _unCommonMaxTokenId;

    uint256 private _rareNextTokenId;
    uint256 private _rareMaxTokenId;

    uint256 private _epicNextTokenId;
    uint256 private _epicMaxTokenId;

    uint256 private _legendaryNextTokenId;
    uint256 private _legendaryMaxTokenId;

    uint256 private _ancientNextTokenId;
    uint256 private _ancientMaxTokenId;

    uint256 private _uniqueNextTokenId;
    uint256 private _uniqueMaxTokenId;

    IDigardERC1155Burnable private _utilityCollectionBurnable;
    IDigardERC1155Mintable private _utilityCollectionMintable;
    IDigardERC1155Upgradeable private _utilityCollection;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address pauser,
        address minter,
        address utilityAddress
    ) public initializer {
        __ERC721_init(
            "ELDA Runes Token Boost Collection",
            "EldarunesTokenBoostCollection"
        );
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __ERC721Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);

        _utilityCollectionBurnable = IDigardERC1155Burnable(utilityAddress);
        _utilityCollectionMintable = IDigardERC1155Mintable(utilityAddress);
        _utilityCollection = IDigardERC1155Upgradeable(utilityAddress);

        _commonNextTokenId = 1;
        _commonMaxTokenId = 10000;

        _unCommonNextTokenId = 10001;
        _unCommonMaxTokenId = 15000;

        _rareNextTokenId = 15001;
        _rareMaxTokenId = 20000;

        _epicNextTokenId = 20001;
        _epicMaxTokenId = 25000;

        _legendaryNextTokenId = 25001;
        _legendaryMaxTokenId = 30000;

        _ancientNextTokenId = 30001;
        _ancientMaxTokenId = 35000;

        _uniqueNextTokenId = 35001;
        _uniqueMaxTokenId = 40000;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://cdn.digard.io/Eldarune/EldarunesTokenBoostCollection/";
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function setUtilityAddress(
        address utilityAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _utilityCollectionBurnable = IDigardERC1155Burnable(utilityAddress);
        _utilityCollectionMintable = IDigardERC1155Mintable(utilityAddress);
        _utilityCollection = IDigardERC1155Upgradeable(utilityAddress);
    }

    function setTokenCapabilities() external onlyRole(MINTER_ROLE) {
        _commonNextTokenId = 12;
        _commonMaxTokenId = 10000;

        _unCommonNextTokenId = 10021;
        _unCommonMaxTokenId = 15000;

        _rareNextTokenId = 15015;
        _rareMaxTokenId = 20000;

        _epicNextTokenId = 20005;
        _epicMaxTokenId = 25000;

        _legendaryNextTokenId = 25001;
        _legendaryMaxTokenId = 30000;

        _ancientNextTokenId = 30007;
        _ancientMaxTokenId = 35000;

        _uniqueNextTokenId = 35005;
        _uniqueMaxTokenId = 40000;
    }

    function _safeConvert(uint256 rarityId, address to) private {
        uint256 tokenId;
        string memory uri;
        if (rarityId == 1 && _commonNextTokenId <= _commonMaxTokenId) {
            _commonNextTokenId++;
            tokenId = _commonNextTokenId;
            uri = "common.json";
        }
        if (rarityId == 2 && _unCommonNextTokenId <= _unCommonMaxTokenId) {
            _unCommonNextTokenId++;
            tokenId = _unCommonNextTokenId;
            uri = "uncommon.json";
        }
        if (rarityId == 3 && _rareNextTokenId <= _rareMaxTokenId) {
            _rareNextTokenId++;
            tokenId = _rareNextTokenId;
            uri = "rare.json";
        }
        if (rarityId == 4 && _epicNextTokenId <= _epicMaxTokenId) {
            _epicNextTokenId++;
            tokenId = _epicNextTokenId;
            uri = "epic.json";
        }
        if (rarityId == 5 && _legendaryNextTokenId <= _legendaryMaxTokenId) {
            _legendaryNextTokenId++;
            tokenId = _legendaryNextTokenId;
            uri = "legendary.json";
        }
        if (rarityId == 6 && _ancientNextTokenId <= _ancientMaxTokenId) {
            _ancientNextTokenId++;
            tokenId = _ancientNextTokenId;
            uri = "ancient.json";
        }
        if (rarityId == 7 && _uniqueNextTokenId <= _uniqueMaxTokenId) {
            _uniqueNextTokenId++;
            tokenId = _uniqueNextTokenId;
            uri = "unique.json";
        }
        require(tokenId > 0, "Undefined tokenId");
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function safeMint(
        uint256 rarityId,
        address to
    ) public onlyRole(MINTER_ROLE) {
        uint256 tokenId;
        string memory uri;
        if (rarityId == 1 && _commonNextTokenId <= _commonMaxTokenId) {
            _commonNextTokenId++;
            tokenId = _commonNextTokenId;
            uri = "common.json";
        } else if (
            rarityId == 2 && _unCommonNextTokenId <= _unCommonMaxTokenId
        ) {
            _unCommonNextTokenId++;
            tokenId = _unCommonNextTokenId;
            uri = "uncommon.json";
        } else if (rarityId == 3 && _rareNextTokenId <= _rareMaxTokenId) {
            _rareNextTokenId++;
            tokenId = _rareNextTokenId;
            uri = "rare.json";
        } else if (rarityId == 4 && _epicNextTokenId <= _epicMaxTokenId) {
            _epicNextTokenId++;
            tokenId = _epicNextTokenId;
            uri = "epic.json";
        } else if (
            rarityId == 5 && _legendaryNextTokenId <= _legendaryMaxTokenId
        ) {
            _legendaryNextTokenId++;
            tokenId = _legendaryNextTokenId;
            uri = "legendary.json";
        } else if (rarityId == 6 && _ancientNextTokenId <= _ancientMaxTokenId) {
            _ancientNextTokenId++;
            tokenId = _ancientNextTokenId;
            uri = "ancient.json";
        } else if (rarityId == 7 && _uniqueNextTokenId <= _uniqueMaxTokenId) {
            _uniqueNextTokenId++;
            tokenId = _uniqueNextTokenId;
            uri = "unique.json";
        }
        require(tokenId > 0, "Undefined tokenId");
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function getTokenIds(
        uint256[] memory _tokenIds
    ) public view returns (uint256[] memory) {
        uint256[] memory rtn = new uint256[](2);

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            uint256 rarityId;
            require(ownerOf(tokenId) == _msgSender(), "No owner");
            if (tokenId <= _commonMaxTokenId) {
                rarityId = 1;
            } else if (
                tokenId > _commonMaxTokenId && tokenId <= _unCommonMaxTokenId
            ) {
                rarityId = 2;
            } else if (
                tokenId > _unCommonMaxTokenId && tokenId <= _rareMaxTokenId
            ) {
                rarityId = 3;
            } else if (
                tokenId > _rareMaxTokenId && tokenId <= _epicMaxTokenId
            ) {
                rarityId = 4;
            } else if (
                tokenId > _epicMaxTokenId && tokenId <= _legendaryMaxTokenId
            ) {
                rarityId = 5;
            } else if (
                tokenId > _legendaryMaxTokenId && tokenId <= _ancientMaxTokenId
            ) {
                rarityId = 6;
            } else if (
                tokenId > _ancientMaxTokenId && tokenId <= _uniqueMaxTokenId
            ) {
                rarityId = 7;
            }
            rtn[i] = rarityId;
        }
        return rtn;
    }

    function deposit(
        uint256 rarityId,
        uint256 amount
    ) public nonReentrant whenNotPaused {
        uint256 rarityBalance = _utilityCollection.balanceOf(
            _msgSender(),
            rarityId
        );
        require(rarityBalance >= amount, "Insufficient utility amount");

        for (uint256 i = 0; i < amount; ) {
            _safeConvert(rarityId, _msgSender());
            unchecked {
                i++;
            }
        }
        _utilityCollectionBurnable.burn(_msgSender(), rarityId, amount);
    }

    function withdraw(
        uint256[] memory tokenIds
    ) public nonReentrant whenNotPaused {
        require(tokenIds.length > 0, "No token");
        for (uint256 i = 0; i < tokenIds.length; ) {
            uint256 tokenId = tokenIds[i];
            uint256 rarityId;
            require(ownerOf(tokenId) == _msgSender(), "No owner");
            if (tokenId <= _commonMaxTokenId) {
                _utilityCollectionMintable.mint(_msgSender(), 1, 1, "0x");
            } else if (
                tokenId > _commonMaxTokenId && tokenId <= _unCommonMaxTokenId
            ) {
                _utilityCollectionMintable.mint(_msgSender(), 2, 1, "0x");
            } else if (
                tokenId > _unCommonMaxTokenId && tokenId <= _rareMaxTokenId
            ) {
                _utilityCollectionMintable.mint(_msgSender(), 3, 1, "0x");
            } else if (
                tokenId > _rareMaxTokenId && tokenId <= _epicMaxTokenId
            ) {
                _utilityCollectionMintable.mint(_msgSender(), 4, 1, "0x");
            } else if (
                tokenId > _epicMaxTokenId && tokenId <= _legendaryMaxTokenId
            ) {
                _utilityCollectionMintable.mint(_msgSender(), 5, 1, "0x");
            } else if (
                tokenId > _legendaryMaxTokenId && tokenId <= _ancientMaxTokenId
            ) {
                _utilityCollectionMintable.mint(_msgSender(), 6, 1, "0x");
            } else if (
                tokenId > _ancientMaxTokenId && tokenId <= _uniqueMaxTokenId
            ) {
                _utilityCollectionMintable.mint(_msgSender(), 7, 1, "0x");
            }
            _burn(tokenId);

            unchecked {
                i++;
            }
        }
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            ERC721URIStorageUpgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    )
        internal
        override(
            ERC721EnumerableUpgradeable,
            ERC721PausableUpgradeable,
            ERC721Upgradeable
        )
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
