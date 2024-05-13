// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {MerkleProofUpgradeable} from "../Utils/MerkleProofUpgradeable.sol";

contract EldaruneUtilityBox is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable,
    UUPSUpgradeable
{
    using MerkleProofUpgradeable for bytes32[];
    using StringsUpgradeable for uint256;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");

    address _mintOwner;

    uint _tokenIdCounter;

    mapping(address => uint256) mintedList;

    event MintProgramEvent(
        bool whiteListEnabled,
        bytes32 merkleRoot,
        uint64 startDate,
        bool mintEnabled
    );

    event MintedCountEvent(uint mintedCount);
    event MintedTeamAllocationCountEvent(uint mintedCount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC721_init(
            "ELDA Runes Utility Collection",
            "EldaRunesUtilityCollection"
        );
        __ERC721URIStorage_init();
        __Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(BURN_ROLE, msg.sender);

        _mintOwner = msg.sender;
        _tokenIdCounter = 201;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://cdn.digard.io/Eldarune/EldaruneUtilityCollection/";
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(
        address to,
        string memory uri
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _tokenIdCounter++;
        return tokenId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    // The following functions are overrides required by Solidity.

    function _burn(
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function burnForUpgrade(uint256 tokenId) public onlyRole(BURN_ROLE) {
        _burn(tokenId);
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
            AccessControlUpgradeable,
            ERC721URIStorageUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setSaleOwner(
        address payable __saleOwner
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_msgSender() != address(0x0), "Public address is not correct");
        _mintOwner = __saleOwner;
    }

    function toBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function batchMint(
        address[] memory addresses,
        string[] memory tokenUris
    ) public onlyRole(MINTER_ROLE) {
        require(
            addresses.length <= 500,
            "You can only mint up to 500 tokens at once."
        );
        for (uint i = 0; i < addresses.length; i++) {
            safeMint(addresses[i], tokenUris[i]);
        }
    }

    function burnBatch(uint256[] memory tokenIds) public onlyRole(BURN_ROLE) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _burn(tokenIds[i]);
        }
    }

    function ownerOf(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721Upgradeable, IERC721Upgradeable)
        returns (address)
    {
        address owner = _ownerOf(tokenId);
        return owner;
    }

    // ----- Helper functions -----
    /// @notice Get all token ids belonging to an address
    /// @param _owner Wallet to find tokens of
    /// @return  Array of the owned token ids
    function walletOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        uint index = 0;
        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint i = 201; i < _tokenIdCounter; i++) {
            address owner = ownerOf(i);
            if (_owner == owner) {
                tokensId[index] = i;
                index++;
            }
        }
        return tokensId;
    }

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view returns (uint256) {
        require(balanceOf(owner) > 0, "No balance");
        uint256[] memory tokenIds = walletOfOwner(owner);
        return tokenIds[index];
    }

    function totalSupply() public view returns (uint256) {
        uint256 total;
        uint256 lastTokenId = _tokenIdCounter;
        for (uint256 i = 201; i < lastTokenId; i++) {
            address owner = ownerOf(i);
            if (owner != address(0x0)) {
                total++;
            }
        }
        return total;
    }

    function burnAll() external onlyRole(BURN_ROLE) {
        for (uint256 i = 201; i < _tokenIdCounter; i++) {
            address owner = ownerOf(i);
            if (owner != address(0x0)) {
                _burn(i);
            }
        }
    }
}
