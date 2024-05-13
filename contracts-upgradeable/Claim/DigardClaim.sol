// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../Interfaces/IDigardERC1155Mintable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "hardhat/console.sol";

contract DigardClaim is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ADD_CLAIM_ROLE = keccak256("ADD_CLAIM_ROLE");
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _claimIdCounter;

    struct PlayerClaimItem {
        address playerAddress;
        uint256 tokenAmount;
        bool lock;
        ClaimNftItem[] claimNftItems;
    }

    struct ClaimNftItem {
        uint nftContractIndex;
        uint256 tokenId;
        uint256 amount;
        bool deactive;
    }

    struct ClaimNftItemEvent {
        address nftContractAddress;
        uint256 tokenId;
        uint256 amount;
        bool deactive;
    }

    address private _tokenRewardAddress;
    address[] private _nftRewardAddress;
    mapping(address => PlayerClaimItem) private _playerClaimList;
    address[] private _playerAddresses;

    event SaveClaimRewardContractAddress(
        address indexed contractAddress,
        uint tokenStandart
    );

    event PlayerClaimAdded(
        address indexed playerAddress,
        address indexed tokenContractAddress,
        uint256 tokenAmount,
        ClaimNftItemEvent[] claimNftItems,
        address indexed executedAddress
    );

    event PlayerTokenClaimed(
        address indexed playerAddress,
        uint256 tokenAmount
    );

    event PlayerNftClaimed(
        address indexed playerAddress,
        ClaimNftItemEvent[] claimNftItems
    );

    event ChangePlayerClaimLockStatus(
        address indexed playerAddress,
        bool lock,
        address indexed executedAddress
    );

    event ChangeNftClaimStatus(
        address indexed nftContractAddress,
        address indexed playerAddress,
        uint256 tokenId,
        bool deactive,
        address indexed executedAddress
    );
    event ClearPlayerClaim(
        address indexed playerAddress,
        bool indexed clearToken,
        bool indexed clearAllNftAssets,
        ClaimNftItemEvent[] claimNftItems,
        address executedAddress
    );

    //Error-Code:0xFFFF = No claim item

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {}

    function _claimReward(address playerAddress) private {
        require(
            _playerClaimList[playerAddress].playerAddress == playerAddress,
            "No records found"
        );

        require(
            _playerClaimList[playerAddress].claimNftItems.length > 0 ||
                _playerClaimList[playerAddress].tokenAmount > 0,
            "No record found to claim."
        );

        if (_playerClaimList[playerAddress].tokenAmount > 0) {
            IERC20(_tokenRewardAddress).transfer(
                playerAddress,
                _playerClaimList[playerAddress].tokenAmount
            );

            emit PlayerTokenClaimed(
                playerAddress,
                _playerClaimList[playerAddress].tokenAmount
            );

            _playerClaimList[playerAddress].tokenAmount = 0;
        }
        ClaimNftItemEvent[] memory claimNftItems = new ClaimNftItemEvent[](
            _playerClaimList[playerAddress].claimNftItems.length
        );
        for (
            uint256 i = 0;
            i < _playerClaimList[playerAddress].claimNftItems.length;
            i++
        ) {
            ClaimNftItem memory claimNftItem = _playerClaimList[playerAddress]
                .claimNftItems[i];
            address nftContract = _nftRewardAddress[
                claimNftItem.nftContractIndex
            ];
            claimNftItems[i] = ClaimNftItemEvent(
                nftContract,
                claimNftItem.tokenId,
                claimNftItem.amount,
                claimNftItem.deactive
            );

            if (!claimNftItem.deactive) {
                uint tokenStandart = findTokenStandart(nftContract);
                if (
                    tokenStandart == 1155 &&
                    claimNftItem.tokenId > 0 &&
                    claimNftItem.amount > 0
                ) {
                    IDigardERC1155Mintable(nftContract).mint(
                        playerAddress,
                        claimNftItem.tokenId,
                        claimNftItem.amount,
                        "0x0"
                    );

                    _playerClaimList[playerAddress].claimNftItems[i].amount = 0;
                }
            }
        }
        emit PlayerNftClaimed(playerAddress, claimNftItems);
    }

    function initialize(
        address tokenRewardAddress,
        address[] memory nftRewardAddress
    ) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(ADD_CLAIM_ROLE, msg.sender);
        saveClaimRewardContractAddress(tokenRewardAddress, nftRewardAddress);
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

    function saveClaimRewardContractAddress(
        address tokenRewardAddress,
        address[] memory nftRewardAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _tokenRewardAddress = tokenRewardAddress;
        emit SaveClaimRewardContractAddress(tokenRewardAddress, 20);

        for (uint i = 0; i < nftRewardAddress.length; i++) {
            _nftRewardAddress[i] = nftRewardAddress[i];
            uint tokenStandart = findTokenStandart(nftRewardAddress[i]);
            emit SaveClaimRewardContractAddress(
                nftRewardAddress[i],
                tokenStandart
            );
        }
    }

    function findTokenStandart(
        address contractAddress
    ) private view returns (uint) {
        uint _tokenStandart = 0;
        if (
            IERC165Upgradeable(contractAddress).supportsInterface(
                type(IERC20).interfaceId
            )
        ) {
            _tokenStandart = 20;
        } else if (
            IERC165Upgradeable(contractAddress).supportsInterface(
                type(IERC721Upgradeable).interfaceId
            )
        ) {
            _tokenStandart = 721;
        } else if (
            IERC165Upgradeable(contractAddress).supportsInterface(
                type(IERC1155Upgradeable).interfaceId
            )
        ) {
            _tokenStandart = 1155;
        }
        return _tokenStandart;
    }

    function addPlayerToken(
        address playerAddress,
        uint256 amount
    ) public onlyRole(ADD_CLAIM_ROLE) {
        if (_playerClaimList[playerAddress].playerAddress == address(0)) {
            _playerAddresses.push(playerAddress);
        }
        _playerClaimList[playerAddress].playerAddress = playerAddress;
        _playerClaimList[playerAddress].tokenAmount += amount;

        ClaimNftItemEvent[] memory claimNftItemsEvent = new ClaimNftItemEvent[](
            0
        );
        emit PlayerClaimAdded(
            playerAddress,
            _tokenRewardAddress,
            amount,
            claimNftItemsEvent,
            _msgSender()
        );
    }

    function addPlayerClaimNft(
        address playerAddress,
        uint256 nftContractIndex,
        uint256 tokenId,
        uint256 amount
    ) public onlyRole(ADD_CLAIM_ROLE) {
        if (_playerClaimList[playerAddress].playerAddress == address(0)) {
            _playerAddresses.push(playerAddress);
        }
        _playerClaimList[playerAddress].playerAddress = playerAddress;
        address nftContract = _nftRewardAddress[nftContractIndex];
        if (nftContract != address(0x0)) {
            bool savedFlag;
            for (
                uint256 p = 0;
                p < _playerClaimList[playerAddress].claimNftItems.length;
                p++
            ) {
                ClaimNftItem memory _claimNftItem = _playerClaimList[
                    playerAddress
                ].claimNftItems[p];

                if (
                    _claimNftItem.nftContractIndex == nftContractIndex &&
                    _claimNftItem.tokenId == tokenId
                ) {
                    _playerClaimList[playerAddress]
                        .claimNftItems[p]
                        .amount += amount;
                    savedFlag = true;
                }
            }
            if (savedFlag == false) {
                ClaimNftItem memory claimNftItem = ClaimNftItem(
                    nftContractIndex,
                    tokenId,
                    amount,
                    false
                );
                _playerClaimList[playerAddress].claimNftItems.push(
                    claimNftItem
                );
            }
            ClaimNftItemEvent[]
                memory claimNftItemsEvent = new ClaimNftItemEvent[](1);
            claimNftItemsEvent[0] = ClaimNftItemEvent(
                nftContract,
                tokenId,
                amount,
                false
            );
            emit PlayerClaimAdded(
                playerAddress,
                _tokenRewardAddress,
                0,
                claimNftItemsEvent,
                _msgSender()
            );
        }
    }

    function addPlayerClaimBatch(
        PlayerClaimItem[] memory playerClaimItems
    ) public onlyRole(ADD_CLAIM_ROLE) {
        require(playerClaimItems.length > 0, "No player claim items");

        for (uint256 i = 0; i < playerClaimItems.length; i++) {
            address playerAddress = playerClaimItems[i].playerAddress;
            uint256 tokenAmount = playerClaimItems[i].tokenAmount * 10 ** 18;

            if (_playerClaimList[playerAddress].playerAddress == address(0)) {
                _playerAddresses.push(playerAddress);
            }
            _playerClaimList[playerAddress].tokenAmount += tokenAmount;
            _playerClaimList[playerAddress].playerAddress = playerAddress;

            for (
                uint256 n = 0;
                n < playerClaimItems[i].claimNftItems.length;
                n++
            ) {
                ClaimNftItem memory claimNftItem = playerClaimItems[i]
                    .claimNftItems[n];
                address nftContract = _nftRewardAddress[
                    claimNftItem.nftContractIndex
                ];

                if (nftContract != address(0x0)) {
                    bool savedFlag;
                    for (
                        uint256 p = 0;
                        p <
                        _playerClaimList[playerAddress].claimNftItems.length;
                        p++
                    ) {
                        ClaimNftItem memory _claimNftItem = _playerClaimList[
                            playerAddress
                        ].claimNftItems[p];

                        if (
                            _claimNftItem.nftContractIndex ==
                            claimNftItem.nftContractIndex &&
                            _claimNftItem.tokenId == claimNftItem.tokenId
                        ) {
                            _playerClaimList[playerAddress]
                                .claimNftItems[p]
                                .amount += claimNftItem.amount;
                            savedFlag = true;
                        }
                    }
                    if (savedFlag == false) {
                        _playerClaimList[playerAddress].claimNftItems.push(
                            claimNftItem
                        );
                    }
                }
            }
            ClaimNftItemEvent[]
                memory claimNftItemsEvent = new ClaimNftItemEvent[](
                    playerClaimItems[i].claimNftItems.length
                );
            for (
                uint e = 0;
                e < playerClaimItems[i].claimNftItems.length;
                e++
            ) {
                ClaimNftItem memory claimNftItem = playerClaimItems[i]
                    .claimNftItems[e];
                address nftContract = _nftRewardAddress[
                    claimNftItem.nftContractIndex
                ];
                claimNftItemsEvent[e] = ClaimNftItemEvent(
                    nftContract,
                    claimNftItem.tokenId,
                    claimNftItem.amount,
                    claimNftItem.deactive
                );
            }
            emit PlayerClaimAdded(
                playerAddress,
                _tokenRewardAddress,
                tokenAmount,
                claimNftItemsEvent,
                _msgSender()
            );
        }
    }

    function claimRewards() public {
        _claimReward(_msgSender());
    }

    function changeClaimNftContractStatus(
        uint _nftContractIndex,
        bool _deactive
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address nftContract = _nftRewardAddress[_nftContractIndex];
        require(nftContract != address(0), "Contract not found");

        for (uint256 i = 0; i < _playerAddresses.length; i++) {
            address playerAddress = _playerAddresses[i];
            for (
                uint256 k = 0;
                k < _playerClaimList[playerAddress].claimNftItems.length;
                k++
            ) {
                ClaimNftItem memory claimNftItem = _playerClaimList[
                    playerAddress
                ].claimNftItems[k];

                if (claimNftItem.nftContractIndex == _nftContractIndex) {
                    console.log(_deactive, "--changeClaimNftContractStatus");
                    _playerClaimList[playerAddress]
                        .claimNftItems[k]
                        .deactive = _deactive;
                    console.log(
                        nftContract,
                        playerAddress,
                        claimNftItem.tokenId,
                        _deactive
                    );
                    emit ChangeNftClaimStatus(
                        nftContract,
                        playerAddress,
                        claimNftItem.tokenId,
                        _deactive,
                        _msgSender()
                    );
                }
            }
        }
    }

    function changePlayerClaimLockStatus(
        address playerAddress,
        bool lock
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _playerClaimList[playerAddress].playerAddress != address(0),
            "Playeraddress not found"
        );
        _playerClaimList[playerAddress].lock = lock;
        emit ChangePlayerClaimLockStatus(playerAddress, lock, _msgSender());
    }

    function clearPlayerClaim(
        address playerAddress,
        bool clearTokenAmount,
        bool clearAllNftAssets
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _playerClaimList[playerAddress].playerAddress != address(0),
            "Playeraddress not found"
        );
        require(
            clearTokenAmount || clearAllNftAssets,
            "No claim found to clear"
        );
        ClaimNftItemEvent[] memory claimNftItemsEvent = new ClaimNftItemEvent[](
            _playerClaimList[playerAddress].claimNftItems.length
        );
        if (clearTokenAmount) _playerClaimList[playerAddress].tokenAmount = 0;
        if (clearAllNftAssets) {
            for (
                uint256 i = 0;
                i < _playerClaimList[playerAddress].claimNftItems.length;
                i++
            ) {
                address nftContract = _nftRewardAddress[
                    _playerClaimList[playerAddress]
                        .claimNftItems[i]
                        .nftContractIndex
                ];
                claimNftItemsEvent[i] = ClaimNftItemEvent(
                    nftContract,
                    _playerClaimList[playerAddress].claimNftItems[i].tokenId,
                    _playerClaimList[playerAddress].claimNftItems[i].amount,
                    _playerClaimList[playerAddress].claimNftItems[i].deactive
                );
                delete _playerClaimList[playerAddress].claimNftItems[i];
            }
        }
        emit ClearPlayerClaim(
            playerAddress,
            clearTokenAmount,
            clearAllNftAssets,
            claimNftItemsEvent,
            _msgSender()
        );
    }

    function clearPlayerNft(
        address playerAddress,
        ClaimNftItem[] memory claimNftItems
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(claimNftItems.length > 0, "No claim found to clear");

        ClaimNftItemEvent[] memory claimNftItemsEvent = new ClaimNftItemEvent[](
            _playerClaimList[playerAddress].claimNftItems.length
        );
        for (
            uint256 i = 0;
            i < _playerClaimList[playerAddress].claimNftItems.length;
            i++
        ) {
            address nftContract = _nftRewardAddress[
                _playerClaimList[playerAddress]
                    .claimNftItems[i]
                    .nftContractIndex
            ];
            for (uint256 k = 0; k < claimNftItems.length; k++) {
                if (
                    claimNftItems[k].nftContractIndex ==
                    _playerClaimList[playerAddress]
                        .claimNftItems[i]
                        .nftContractIndex &&
                    claimNftItems[k].tokenId ==
                    _playerClaimList[playerAddress].claimNftItems[i].tokenId
                ) {
                    claimNftItemsEvent[i] = ClaimNftItemEvent(
                        nftContract,
                        _playerClaimList[playerAddress]
                            .claimNftItems[i]
                            .tokenId,
                        _playerClaimList[playerAddress].claimNftItems[i].amount,
                        _playerClaimList[playerAddress]
                            .claimNftItems[i]
                            .deactive
                    );
                    delete _playerClaimList[playerAddress].claimNftItems[i];
                }
            }
        }
        emit ClearPlayerClaim(
            playerAddress,
            false,
            false,
            claimNftItemsEvent,
            _msgSender()
        );
    }

    function updatePlayerNft(
        address playerAddress,
        ClaimNftItem[] memory claimNftItems
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(claimNftItems.length > 0, "No claim found to clear");

        ClaimNftItemEvent[] memory claimNftItemsEvent = new ClaimNftItemEvent[](
            _playerClaimList[playerAddress].claimNftItems.length
        );
        for (
            uint256 i = 0;
            i < _playerClaimList[playerAddress].claimNftItems.length;
            i++
        ) {
            address nftContract = _nftRewardAddress[
                _playerClaimList[playerAddress]
                    .claimNftItems[i]
                    .nftContractIndex
            ];
            for (uint256 k = 0; k < claimNftItems.length; k++) {
                if (
                    claimNftItems[k].nftContractIndex ==
                    _playerClaimList[playerAddress]
                        .claimNftItems[i]
                        .nftContractIndex &&
                    claimNftItems[k].tokenId ==
                    _playerClaimList[playerAddress].claimNftItems[i].tokenId
                ) {
                    claimNftItemsEvent[i] = ClaimNftItemEvent(
                        nftContract,
                        _playerClaimList[playerAddress]
                            .claimNftItems[i]
                            .tokenId,
                        _playerClaimList[playerAddress].claimNftItems[i].amount,
                        _playerClaimList[playerAddress]
                            .claimNftItems[i]
                            .deactive
                    );
                    if (
                        (_playerClaimList[playerAddress]
                            .claimNftItems[i]
                            .amount - claimNftItems[k].amount) >= 0
                    ) {
                        _playerClaimList[playerAddress]
                            .claimNftItems[i]
                            .amount -= claimNftItems[k].amount;
                    }
                }
            }
        }
        emit PlayerNftClaimed(playerAddress, claimNftItemsEvent);
    }

    function getRewardContractIndex(
        address addr
    ) internal view returns (int256) {
        int256 rewardNftIndex = -1;
        for (uint256 i = 0; i < _nftRewardAddress.length; i++) {
            if (_nftRewardAddress[i] == addr) {
                rewardNftIndex = int256(i);
            }
        }
        return rewardNftIndex;
    }

    function getRewardContractByIndex(
        uint256 index
    ) external view returns (address) {
        return _nftRewardAddress[index];
    }

    function claimRewardOwner(
        address playerAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _claimReward(playerAddress);
    }

    function getPlayerClaimList(
        address playerAddress
    )
        external
        view
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (ClaimNftItem[] memory)
    {
        return _playerClaimList[playerAddress].claimNftItems;
    }

    function getAcceptedNftRewardAddress()
        external
        view
        returns (address[] memory)
    {
        address[] memory _nftRewardAddressList = new address[](
            _nftRewardAddress.length
        );
        for (uint256 i = 0; i < _nftRewardAddress.length; i++) {
            _nftRewardAddressList[i] = _nftRewardAddress[i];
        }
        return _nftRewardAddressList;
    }
}
