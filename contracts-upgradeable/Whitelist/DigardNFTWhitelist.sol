// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../Utils/AddressStringConverter.sol";

contract DigardNFTWhitelist is
    Initializable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant WHITELIST_ADDED_ROLE =
        keccak256("WHITELIST_ADDED_ROLE");
    using StringsUpgradeable for uint256;
    using AddressStringConverter for address;
    struct WhitelistInformation {
        address[] whiteListAddresses;
        address tokenAddress;
        uint256 tokenId;
    }
    event SaveWhitelist(
        address[] whiteListAddresses,
        address tokenAddress,
        uint256 tokenId
    );
    event RemoveWhitelist(
        address[] whiteListAddresses,
        address tokenAddress,
        uint256 tokenId
    );
    mapping(address => mapping(string => bool)) public _whiteListAddresses;

    constructor() {}

    function initialize() public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(WHITELIST_ADDED_ROLE, msg.sender);
    }

    function grantAdminRole() public {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function _doWhitelist(
        WhitelistInformation memory _whiteListInformation,
        bool whitelistState
    ) private {
        for (
            uint256 k = 0;
            k < _whiteListInformation.whiteListAddresses.length;
            k++
        ) {
            address whiteList = _whiteListInformation.whiteListAddresses[k];

            string memory id = string.concat(
                _whiteListInformation.tokenAddress.addressToString(),
                "_",
                _whiteListInformation.tokenId.toString()
            );

            _whiteListAddresses[whiteList][id] = whitelistState;
        }
    }

    function saveWhitelist(
        WhitelistInformation memory _whiteListInformation
    ) external onlyRole(WHITELIST_ADDED_ROLE) {
        require(
            _whiteListInformation.whiteListAddresses.length > 0,
            "No whitelist"
        );
        _doWhitelist(_whiteListInformation, true);
        emit SaveWhitelist(
            _whiteListInformation.whiteListAddresses,
            _whiteListInformation.tokenAddress,
            _whiteListInformation.tokenId
        );
    }

    function removeWhitelist(
        WhitelistInformation memory _whiteListInformation
    ) external onlyRole(WHITELIST_ADDED_ROLE) {
        require(
            _whiteListInformation.whiteListAddresses.length > 0,
            "No whitelist"
        );
        _doWhitelist(_whiteListInformation, false);
        emit RemoveWhitelist(
            _whiteListInformation.whiteListAddresses,
            _whiteListInformation.tokenAddress,
            _whiteListInformation.tokenId
        );
    }

    function getWhitelist(
        address whitelistAddress,
        address tokenAddress,
        uint256 tokenId
    ) public view returns (bool) {
        string memory id = string(
            abi.encodePacked(
                tokenAddress.addressToString(),
                "_",
                tokenId.toString()
            )
        );
        return _whiteListAddresses[whitelistAddress][id];
    }
}
