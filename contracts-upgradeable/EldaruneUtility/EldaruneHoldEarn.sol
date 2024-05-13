// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "../Interfaces/IDigardERC1155Upgradeable.sol";
import "../Interfaces/IDigardERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "hardhat/console.sol";

contract EldaruneHoldEarn is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    IDigardERC1155ReceiverUpgradeable
{
    bytes32 public constant PROGRAM_MODIFIER_ROLE =
        keccak256("PROGRAM_MODIFIER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    address _utilityAddress;

    event JoinHoldEarn(uint256 tokenId, uint256 balance, address sender);

    event HoldEarnEnabled(bool active);

    mapping(address => mapping(uint256 => uint256)) _holdEarns;
    bool private _holdEarnActive;

    constructor() {}

    function initialize(address utilityAddress) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PROGRAM_MODIFIER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _utilityAddress = utilityAddress;
        _holdEarnActive = false;
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

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external virtual override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external virtual override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    function setHoldEarnActive(
        bool _active
    ) external onlyRole(PROGRAM_MODIFIER_ROLE) {
        _holdEarnActive = _active;
        emit HoldEarnEnabled(_active);
    }

    function joinHoldEarn(uint256 tokenId) public {
        uint256 balance = IDigardERC1155Upgradeable(_utilityAddress).balanceOf(
            _msgSender(),
            tokenId
        );
        require(balance > 0, "No utility balance");
        _holdEarns[_msgSender()][tokenId] = balance;
        emit JoinHoldEarn(tokenId, balance, _msgSender());
    }

    function getFuckOff(
        address msgSender,
        uint256 tokenId
    ) public view returns (uint256) {
        return _holdEarns[msgSender][tokenId];
    }
}
