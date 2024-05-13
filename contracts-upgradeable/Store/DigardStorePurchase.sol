// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../Interfaces/IDigardERC1155Mintable.sol";
import "../Interfaces/IDigardNFTWhitelist.sol";
import "../Interfaces/IDigardERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

contract DigardStorePurchase is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(uint256 => uint256) private _totalSoldStoreItems;
    mapping(address => mapping(uint256 => uint256))
        private _addressTotalPurchases;

    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
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

    function savePurchase(
        address msgSender,
        uint256 storeItemId,
        uint256 amount
    ) internal nonReentrant whenNotPaused {
        _totalSoldStoreItems[storeItemId] =
            _totalSoldStoreItems[storeItemId] +
            amount;
        _addressTotalPurchases[msgSender][storeItemId] =
            _addressTotalPurchases[msgSender][storeItemId] +
            amount;
    }

    function getTotalPurchaseAmountByAddress(
        address msgSender,
        uint256 storeItemId
    ) external view returns (uint256) {
        return _addressTotalPurchases[msgSender][storeItemId];
    }
}
