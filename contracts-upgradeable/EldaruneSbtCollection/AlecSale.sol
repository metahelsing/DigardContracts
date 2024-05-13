// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../Interfaces/IDigardERC1155Mintable.sol";
import "../Interfaces/IDigardERC20Upgradeable.sol";
import "../Interfaces/IDigardERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract AlecSale is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    address _eldaTokenAddress;
    address _eldarunesAddress;
    uint256 _requiredEldaBalance;
    uint256 _mintTokenId;
    uint256 _whiteListCounter;
    bool _whiteListEnabled;
    bool _active;

    using StringsUpgradeable for uint256;

    mapping(uint256 => address) _whiteList;
    mapping(address => bool) _whiteListNew;

    event SaveInitialize(
        address _eldaTokenAddress,
        address _eldarunesAddress,
        uint256 _tokenId,
        uint256 _requiredEldaBalance,
        bool _active,
        bool _whiteListEnabled
    );

    event SaveWhiteList(address whiteListAddress, uint256 whiteListCounter);

    event MintAlec(
        uint256 tokenId,
        uint256 amountRequired,
        address minterAddress
    );

    function initialize(
        address __eldaTokenAddress,
        address __eldarunesAddress,
        address[] memory __whiteList,
        uint256 __requiredEldaBalance,
        uint256 __mintTokenId,
        bool __whiteListEnabled
    ) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        saveInitialize(
            __eldaTokenAddress,
            __eldarunesAddress,
            __whiteList,
            __requiredEldaBalance,
            __mintTokenId,
            __whiteListEnabled,
            true
        );
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
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

    function saveWhiteList(
        address[] memory __whiteList
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < __whiteList.length; i++) {
            _whiteListNew[__whiteList[i]] = true;
            emit SaveWhiteList(__whiteList[i], _whiteListCounter);
        }
    }

    function resetWhiteList() public onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < _whiteListCounter; i++) {
            delete _whiteList[i];
        }
    }

    function saveInitialize(
        address __eldaTokenAddress,
        address __eldarunesAddress,
        address[] memory __whiteList,
        uint256 __requiredEldaBalance,
        uint256 __mintTokenId,
        bool __active,
        bool __whiteListEnabled
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _eldaTokenAddress = __eldaTokenAddress;
        _eldarunesAddress = __eldarunesAddress;
        if (__whiteListEnabled) {
            saveWhiteList(__whiteList);
        }
        _requiredEldaBalance = __requiredEldaBalance * 10 ** 18;
        _mintTokenId = __mintTokenId;
        _active = __active;
        _whiteListEnabled = __whiteListEnabled;
        emit SaveInitialize(
            __eldaTokenAddress,
            __eldarunesAddress,
            __mintTokenId,
            _requiredEldaBalance,
            __active,
            __whiteListEnabled
        );
    }

    function mintAlec() public nonReentrant whenNotPaused {
        if (_whiteListEnabled) {
            require(
                _whiteListNew[_msgSender()] == true,
                "You are not registered on the whitelist"
            );
        }
        require(
            IDigardERC20Upgradeable(_eldaTokenAddress).balanceOf(
                _msgSender()
            ) >= _requiredEldaBalance,
            string(
                abi.encodePacked(
                    "You must have a minimum balance of ",
                    _requiredEldaBalance.toString(),
                    " Elda tokens or more"
                )
            )
        );

        require(
            IDigardERC1155Upgradeable(_eldarunesAddress).balanceOf(
                _msgSender(),
                _mintTokenId
            ) == 0,
            "You cannot mint again that you have the Alec balance."
        );

        IDigardERC1155Mintable(_eldarunesAddress).mint(
            _msgSender(),
            _mintTokenId,
            1,
            "0x"
        );

        emit MintAlec(_mintTokenId, _requiredEldaBalance, _msgSender());
    }

    function mintAlecOwner(
        address msgSender
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_whiteListEnabled) {
            require(
                _whiteListNew[_msgSender()] == true,
                "You are not registered on the whitelist"
            );
        }
        require(
            IDigardERC20Upgradeable(_eldaTokenAddress).balanceOf(msgSender) >=
                _requiredEldaBalance,
            string(
                abi.encodePacked(
                    "You must have a minimum balance of ",
                    _requiredEldaBalance.toString(),
                    " Elda tokens or more"
                )
            )
        );

        require(
            IDigardERC1155Upgradeable(_eldarunesAddress).balanceOf(
                msgSender,
                _mintTokenId
            ) == 0,
            "You cannot mint again that you have the Alec balance."
        );

        IDigardERC1155Mintable(_eldarunesAddress).mint(
            msgSender,
            _mintTokenId,
            1,
            "0x"
        );

        emit MintAlec(_mintTokenId, _requiredEldaBalance, msgSender);
    }

    function checkWhiteList(
        address whiteListAddress
    ) public view returns (bool) {
        return _whiteListNew[whiteListAddress];
    }
}
