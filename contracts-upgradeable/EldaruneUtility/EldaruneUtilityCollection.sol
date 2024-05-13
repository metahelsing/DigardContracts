// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../Interfaces/IDigardNFTDistribution.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";

contract EldaruneUtilityCollection is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ERC1155BurnableUpgradeable,
    ERC1155SupplyUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    using StringsUpgradeable for uint256;

    uint256 private constant common = 1;
    uint256 private constant uncommon = 2;
    uint256 private constant rare = 3;
    uint256 private constant epic = 4;
    uint256 private constant legendary = 5;
    uint256 private constant ancient = 6;
    uint256 private constant unique = 7;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {}

    function initialize() public initializer {
        __ERC1155_init(
            "https://cdn.digard.io/Eldarune/EldaruneUtilityCollection/metadata/"
        );
        __AccessControl_init();
        __Pausable_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
        _name = "EldaruneUtilityCollection";
        _symbol = "EldaruneUtilityCollection";
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function setTokenInformation(
        string memory __name,
        string memory __symbol
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _name = __name;
        _symbol = __symbol;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mintBatch(to, ids, amounts, data);
    }

    function mintAddressBatch(
        address[] memory toAddresses,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        for (uint256 i = 0; i < toAddresses.length; i++) {
            _mintBatch(toAddresses[i], ids, amounts, data);
        }
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
        whenNotPaused
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function uri(uint256 tokenId) public pure override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "https://cdn.digard.io/Eldarune/EldaruneUtilityCollection/metadata/",
                    tokenId.toString(),
                    ".json"
                )
            );
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // ----- Helper functions -----
    /// @notice Get all token ids belonging to an address
    /// @param _owner Wallet to find tokens of
    /// @return  Array of the owned token ids
    function walletOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 index;
        uint256[] memory _tokensId = new uint256[](7);
        for (uint i = 1; i < 8; i++) {
            if (balanceOf(_owner, i) > 0) {
                _tokensId[index] = i;
                index++;
            }
        }
        uint256[] memory tokensId = new uint256[](index);
        for (uint i = 0; i < _tokensId.length; i++) {
            if (_tokensId[i] > 0) {
                tokensId[i] = _tokensId[i];
            }
        }
        return tokensId;
    }

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view returns (uint256) {
        uint256[] memory tokenIds = walletOfOwner(owner);
        return tokenIds[index];
    }
}
