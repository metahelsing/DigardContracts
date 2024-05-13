// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../../Interfaces/IDigardERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./IDigardERC20Burnable.sol";

contract EldaPoolManager is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    address _eldaTokenAddress;
    uint256 _poolIndex;
    bool _autoBurn;
    uint256 _burnRatio;
    uint256 decimal;

    struct PoolManager {
        address poolAddress;
        bool enabled;
    }

    struct TransferList {
        address walletAddress;
        uint256 amount;
    }

    mapping(uint256 => PoolManager) _poolList;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    event PoolSave(address poolAddress, bool enabled);

    event PoolDistribution(address poolAddress, uint256 amount);

    event PoolBurnEnable(bool burnEnable, uint256 burnRatio);

    function initialize(
        address __eldaTokenAddress,
        PoolManager[] memory _poolManager
    ) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        _eldaTokenAddress = __eldaTokenAddress;
        decimal = 10 ** uint256(18);
        savePoolList(_poolManager);
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

    function saveEldaTokenAddress(
        address eldaTokenAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _eldaTokenAddress = eldaTokenAddress;
    }

    function savePoolList(
        PoolManager[] memory _poolManager
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_poolManager.length > 0, "PoolManager is empty");
        for (uint256 i = 0; i < _poolManager.length; i++) {
            _poolList[i] = _poolManager[i];
            emit PoolSave(_poolManager[i].poolAddress, _poolManager[i].enabled);
        }
        _poolIndex = _poolManager.length;
    }

    function enableBurn(
        bool burnEnable,
        uint256 burnRatio
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _autoBurn = burnEnable;
        _burnRatio = burnRatio;
        emit PoolBurnEnable(burnEnable, burnRatio);
    }

    function distributionBalance() public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_poolIndex > 0, "Pool list is empty");
        uint256 amount = IDigardERC20Upgradeable(_eldaTokenAddress).balanceOf(
            address(this)
        );
        require(amount >= _poolIndex, "Pool manager balance is empty");
        if (_autoBurn) {
            require(_burnRatio > 0, "Burn ratio is empty");
            uint256 burnAmount = (amount * _burnRatio) / 100;
            IDigardERC20Burnable(_eldaTokenAddress).burn(burnAmount);
            amount -= burnAmount;
        }
        uint256 distributionLength;
        for (uint256 i = 0; i < _poolIndex; i++) {
            if (_poolList[i].enabled) {
                distributionLength++;
            }
        }
        uint256 distributionAmount = amount / distributionLength;
        for (uint256 i = 0; i < _poolIndex; i++) {
            if (_poolList[i].enabled) {
                IDigardERC20Upgradeable(_eldaTokenAddress).transfer(
                    _poolList[i].poolAddress,
                    distributionAmount
                );
                emit PoolDistribution(
                    _poolList[i].poolAddress,
                    distributionAmount
                );
            }
        }
    }

    function burn(uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IDigardERC20Burnable(_eldaTokenAddress).burn(amount);
    }

    function _transferBatch(address poolAddress, uint256 amount) private {
        IDigardERC20Upgradeable(_eldaTokenAddress).transfer(
            poolAddress,
            amount
        );
        emit PoolDistribution(poolAddress, amount);
    }

    function transferBatch(
        TransferList[] memory transferList
    ) public onlyRole(TRANSFER_ROLE) {
        require(transferList.length > 0, "No transferList");
        uint256[] memory poolBalances = new uint256[](_poolIndex);
        uint256 currentPoolIndex = 0;
        for (uint256 i; i < _poolIndex; i++) {
            uint256 amount = IDigardERC20Upgradeable(_eldaTokenAddress)
                .balanceOf(_poolList[i].poolAddress);
            poolBalances[i] = amount;
        }

        for (uint256 i; i < transferList.length; i++) {
            if (poolBalances[currentPoolIndex] >= transferList[i].amount) {
                _transferBatch(
                    _poolList[currentPoolIndex].poolAddress,
                    transferList[i].amount
                );
            } else {
                currentPoolIndex++;
                _transferBatch(
                    _poolList[currentPoolIndex].poolAddress,
                    transferList[i].amount
                );
            }
        }
    }
}
