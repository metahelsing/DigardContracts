// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../../../Interfaces/IDigardERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract ELDAPool7 is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant CLAIM_ROLE = keccak256("CLAIM_ROLE");
    address _eldaTokenAddress;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    event PoolClaim(
        address indexed claimerAddress,
        address indexed executedAddress,
        uint256 amount
    );

    function initialize(address __eldaTokenAddress) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(CLAIM_ROLE, msg.sender);

        _eldaTokenAddress = __eldaTokenAddress;
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

    function claim(address to, uint256 amount) public onlyRole(CLAIM_ROLE) {
        require(
            IDigardERC20Upgradeable(_eldaTokenAddress).balanceOf(
                address(this)
            ) >= amount,
            "Insufficient pool balance"
        );
        IDigardERC20Upgradeable(_eldaTokenAddress).transfer(to, amount);
        emit PoolClaim(to, _msgSender(), amount);
    }
}
