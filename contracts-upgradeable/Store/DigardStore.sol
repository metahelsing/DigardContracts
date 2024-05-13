// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../Interfaces/IDigardERC1155Mintable.sol";
import "../Interfaces/IDigardNFTWhitelist.sol";
import "../Interfaces/IDigardERC20Upgradeable.sol";
import "../Interfaces/IDigardERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

contract DigardStore is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ITEM_SAVE_ROLE = keccak256("ITEM_SAVE_ROLE");

    address _paymentContract;
    address _storeOwner;
    IDigardNFTWhitelist _digardNftWhitelist;
    uint256 decimal;

    struct StoreItem {
        uint256 storeItemId;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        uint256 maxPerSoldAmount;
        uint256 maxSoldAmount;
        uint256 startDate;
        uint256 endDate;
        bool active;
        bool whitelistEnabled;
        address nftContract;
    }

    struct StoreItemDiscount {
        uint256 storeItemId;
        uint256 startDate;
        uint256 startBlock;
        uint256 discountRate;
        uint256 reamingAmount;
        uint256[3] timeDuration;
        bool active;
    }

    event SaveStoreItem(
        uint256 storeItemId,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        uint256 maxPerSoldAmount,
        uint256 maxSoldAmount,
        uint256 startDate,
        uint256 endDate,
        address nftContract,
        address executedAddress,
        bool active,
        bool whitelistEnabled
    );

    event SaveStoreItemDiscount(
        uint256 storeItemDiscount,
        uint256 storeItemId,
        uint256 startDate,
        uint256 endDate,
        uint256 discountRate,
        uint256 reamingAmount,
        address executedAddress
    );

    event SaleStoreItem(
        uint256 indexed storeItemId,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 totalPrice,
        uint256 totalSoldAmount,
        address indexed buyerAddress
    );

    event SavePaymentContract(address paymentContract, address executedAddress);

    event TransferAmount(address transferAddress, address executedAddress);

    event SaveSaleOwner(address newSaleOwner, address executedAddress);

    event SaveDigardNftWhitelistContract(
        address digardNftWhitelistContract,
        address executedAddress
    );

    mapping(uint256 => StoreItem) private _storeItems;
    mapping(uint256 => StoreItemDiscount) private _storeItemDiscounts;
    mapping(uint256 => uint256) private _totalSoldStoreItems;
    mapping(address => mapping(uint256 => uint256)) _soldAddressList;

    function initialize(address paymentContract) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(ITEM_SAVE_ROLE, msg.sender);

        _storeOwner = msg.sender;
        _paymentContract = paymentContract;
        if (_paymentContract != address(0)) {
            uint256 _decimal = IERC20MetadataUpgradeable(paymentContract)
                .decimals();
            decimal = 10 ** uint256(_decimal);
        }
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

    function setDecimal() external onlyRole(ADMIN_ROLE) {
        uint256 _decimal = IERC20MetadataUpgradeable(_paymentContract)
            .decimals();
        decimal = 10 ** uint256(_decimal);
    }

    function saveStoreItem(
        StoreItem[] memory __storeItems
    ) public onlyRole(ITEM_SAVE_ROLE) {
        require(__storeItems.length > 0, "No store items");
        address __msgSender = _msgSender();
        for (uint256 i = 0; i < __storeItems.length; i++) {
            _storeItems[__storeItems[i].storeItemId] = StoreItem(
                __storeItems[i].storeItemId,
                __storeItems[i].tokenId,
                __storeItems[i].amount,
                __storeItems[i].price * decimal,
                __storeItems[i].maxPerSoldAmount,
                __storeItems[i].maxSoldAmount,
                __storeItems[i].startDate,
                __storeItems[i].endDate,
                __storeItems[i].active,
                __storeItems[i].whitelistEnabled,
                __storeItems[i].nftContract
            );

            emit SaveStoreItem(
                __storeItems[i].storeItemId,
                __storeItems[i].tokenId,
                __storeItems[i].amount,
                __storeItems[i].price * decimal,
                __storeItems[i].maxPerSoldAmount,
                __storeItems[i].maxSoldAmount,
                __storeItems[i].startDate,
                __storeItems[i].endDate,
                __storeItems[i].nftContract,
                __msgSender,
                __storeItems[i].active,
                __storeItems[i].whitelistEnabled
            );
        }
    }

    function savePaymentContract(
        address paymentContract
    ) public onlyRole(ADMIN_ROLE) {
        require(
            paymentContract != address(0),
            "Payment contract is not dead address"
        );
        require(
            _paymentContract != paymentContract,
            "Payment contract is not same"
        );
        _paymentContract = paymentContract;
        emit SavePaymentContract(paymentContract, _msgSender());
    }

    function saveDigardNftWhitelist(
        address digardNftWhitelistAddress
    ) external onlyRole(ADMIN_ROLE) {
        _digardNftWhitelist = IDigardNFTWhitelist(digardNftWhitelistAddress);
        emit SaveDigardNftWhitelistContract(
            digardNftWhitelistAddress,
            _msgSender()
        );
    }

    function transferSaleTotalAmount(
        address _transferAddress
    ) public onlyRole(ADMIN_ROLE) {
        require(
            _transferAddress != address(0),
            "Transfer address is not dead address"
        );
        uint256 tokenBalance = IDigardERC20Upgradeable(_paymentContract)
            .balanceOf(address(this));
        IDigardERC20Upgradeable(_paymentContract).transfer(
            _transferAddress,
            tokenBalance
        );
        emit TransferAmount(_transferAddress, _msgSender());
    }

    function saveSaleOwner(address _newSaleOwner) public onlyRole(ADMIN_ROLE) {
        require(
            _newSaleOwner != address(0),
            "Sale owner address is not dead address"
        );
        _storeOwner = _newSaleOwner;
        transferSaleTotalAmount(_newSaleOwner);
        emit SaveSaleOwner(_newSaleOwner, _msgSender());
    }

    function saleNft(
        uint256 storeItemId,
        uint256 amount
    ) public nonReentrant whenNotPaused {
        require(
            _storeItems[storeItemId].storeItemId > 0,
            "Not store item found"
        );
        require(_storeItems[storeItemId].active, "Not active store item");
        StoreItem memory storeItem = _storeItems[storeItemId];
        if (storeItem.startDate > 0) {
            require(
                storeItem.startDate <= block.timestamp,
                "The sale has not yet started"
            );
        }
        if (storeItem.endDate > 0) {
            require(storeItem.endDate >= block.timestamp, "Sale completed");
        }
        if (storeItem.maxSoldAmount > 0) {
            uint256 afterSoldAmountTotal = _totalSoldStoreItems[storeItemId] +
                amount;
            require(
                afterSoldAmountTotal <= storeItem.maxSoldAmount,
                "The sale is complete"
            );
        }
        if (storeItem.whitelistEnabled) {
            bool whitelistResult = _digardNftWhitelist.getWhitelist(
                _msgSender(),
                storeItem.nftContract,
                storeItem.tokenId
            );
            require(whitelistResult, "You are not on the whitelist");
        }
        if (storeItem.maxPerSoldAmount > 0) {
            uint256 afterSoldAmountTotal = _soldAddressList[_msgSender()][
                storeItemId
            ] + amount;
            require(
                afterSoldAmountTotal <= storeItem.maxPerSoldAmount,
                "The maximum purchase limit for this nft has been reached"
            );
        }
        uint256 totalPrice = storeItem.price * amount;
        if (totalPrice > 0) {
            require(
                IDigardERC20Upgradeable(_paymentContract).balanceOf(
                    _msgSender()
                ) >= totalPrice,
                "Insufficient balance"
            );
            IDigardERC20Upgradeable(_paymentContract).transferFrom(
                _msgSender(),
                _storeOwner,
                totalPrice
            );
        }

        IDigardERC1155Mintable(storeItem.nftContract).mint(
            _msgSender(),
            storeItem.tokenId,
            amount,
            "0x0"
        );

        _totalSoldStoreItems[storeItemId] += amount;
        _soldAddressList[_msgSender()][storeItemId] += amount;

        emit SaleStoreItem(
            storeItemId,
            storeItem.tokenId,
            amount,
            totalPrice,
            _totalSoldStoreItems[storeItemId],
            _msgSender()
        );
    }
}
