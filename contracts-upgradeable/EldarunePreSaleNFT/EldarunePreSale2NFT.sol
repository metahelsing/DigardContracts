// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "../Interfaces/IDigardERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../Utils/CountersUpgradeable.sol";
import {MerkleProofUpgradeable} from "../Utils/MerkleProofUpgradeable.sol";

contract EldarunePreSale2NFT is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;
    CountersUpgradeable.Counter private _nftPackageCounter;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        SaleProgram memory __saleProgram,
        NftPackageType[] memory __nftPackageTypes,
        address[] memory __paymentContracts,
        address saleOwner
    ) public initializer {
        __ERC721_init("EldarunePreSale2", "ELDAPS2");
        __ERC721URIStorage_init();
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        _saleOwner = saleOwner;
        _saleProgram = __saleProgram;
        _paymentContracts = __paymentContracts;
        for (uint i = 0; i < __nftPackageTypes.length; i++) {
            _nftPackageCounter.increment();
            _nftPackageTypes[__nftPackageTypes[i].typeId] = NftPackageType(
                __nftPackageTypes[i].typeId,
                __nftPackageTypes[i].price,
                __nftPackageTypes[i].uri
            );
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://cdn.digard.io/Eldarune/PreSale2/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override whenNotPaused {
        require(
            from == address(0) || to == address(0),
            "NonTransferrableERC721Token: non transferrable"
        );
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    // The following functions are overrides required by Solidity.

    function _burn(
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function updateNftPackageTypesAndPaymentContracts(
        NftPackageType[] memory __nftPackageTypes,
        address[] memory __paymentContracts
    ) public onlyOwner {
        _paymentContracts = __paymentContracts;
        for (uint i = 0; i < __nftPackageTypes.length; i++) {
            _nftPackageTypes[__nftPackageTypes[i].typeId] = NftPackageType(
                __nftPackageTypes[i].typeId,
                __nftPackageTypes[i].price,
                __nftPackageTypes[i].uri
            );
        }
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

    using MerkleProofUpgradeable for bytes32[];
    address[] _paymentContracts;
    address _saleOwner;
    SaleProgram private _saleProgram;
    mapping(uint256 => BuyerItem) _buyerList;
    mapping(uint => NftPackageType) _nftPackageTypes;
    uint256 _totalSaleGoal;

    struct SaleProgram {
        bool whiteListEnabled;
        bytes32 merkleRoot;
        uint64 startDate;
        uint64 endDate;
    }

    struct NftPackageType {
        uint typeId;
        uint256 price;
        string uri;
    }

    struct BuyerItem {
        uint256 tokenId;
        address buyerAddress;
        address paymentContractAddress;
        uint256 packagePrice;
    }

    struct SaleDetail {
        bytes32[] proof;
        uint nftPackageTypeId;
        address paymentContract;
    }
    event SaleProgramEvent(
        bool whiteListEnabled,
        bytes32 merkleRoot,
        uint64 startDate,
        uint64 endDate
    );
    event NftSaleEvent(
        uint256 tokenId,
        address indexed buyerAddress,
        address indexed paymentContractAddress,
        uint256 indexed packagePrice,
        uint256 totalGoal
    );

    function updateSaleProgram(
        SaleProgram memory __saleProgram
    ) public onlyOwner {
        _saleProgram = __saleProgram;
        emit SaleProgramEvent(
            __saleProgram.whiteListEnabled,
            __saleProgram.merkleRoot,
            __saleProgram.startDate,
            __saleProgram.endDate
        );
    }

    function setSaleOwner(address payable __saleOwner) public onlyOwner {
        require(_msgSender() != address(0x0), "Public address is not correct");
        _saleOwner = __saleOwner;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        _saleProgram.merkleRoot = _merkleRoot;
    }

    function toBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function saleNFT(
        SaleDetail memory _saleDetail
    ) public nonReentrant whenNotPaused {
        require(
            _nftPackageTypes[_saleDetail.nftPackageTypeId].typeId > 0,
            "Undefined sale package"
        );
        require(
            _saleProgram.startDate <= block.timestamp,
            "Sales have not started"
        );
        require(_saleProgram.endDate >= block.timestamp, "Sale has ended");
        require(_msgSender() != address(0x0), "Public address is not correct");
        if (_saleProgram.whiteListEnabled) {
            require(
                MerkleProofUpgradeable.verify(
                    _saleDetail.proof,
                    _saleProgram.merkleRoot,
                    toBytes32(_msgSender())
                ),
                "You are not in the list"
            );
        }
        bool findResult;
        uint paymentContractIndex;
        for (uint i = 0; i < _paymentContracts.length; i++) {
            if (_paymentContracts[i] == _saleDetail.paymentContract) {
                paymentContractIndex = i;
                findResult = true;
            }
        }
        require(findResult, "Undefined payment contract address");
        address paymentContract = _paymentContracts[paymentContractIndex];
        address nftMinter = _msgSender();
        NftPackageType memory nftPackageType = _nftPackageTypes[
            _saleDetail.nftPackageTypeId
        ];
        require(
            IDigardERC20Upgradeable(paymentContract).balanceOf(_msgSender()) >=
                nftPackageType.price,
            "Insufficient balance"
        );
        IDigardERC20Upgradeable(paymentContract).transferFrom(
            nftMinter,
            _saleOwner,
            nftPackageType.price
        );
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _buyerList[tokenId] = BuyerItem(
            tokenId,
            nftMinter,
            _saleDetail.paymentContract,
            nftPackageType.price
        );
        _mint(nftMinter, tokenId);
        _setTokenURI(tokenId, nftPackageType.uri);
        _totalSaleGoal += nftPackageType.price;
        emit NftSaleEvent(
            tokenId,
            nftMinter,
            _saleDetail.paymentContract,
            nftPackageType.price,
            _totalSaleGoal
        );
    }

    function fetchBuyerList()
        public
        view
        onlyOwner
        returns (BuyerItem[] memory)
    {
        uint256 total = _tokenIdCounter.current();
        uint256 index = 0;
        BuyerItem[] memory items = new BuyerItem[](total);
        for (uint256 i = 1; i <= total; i++) {
            items[index] = _buyerList[i];
            index++;
        }
        return items;
    }

    function fetchNFTPackage()
        public
        view
        onlyOwner
        returns (NftPackageType[] memory)
    {
        uint256 total = _nftPackageCounter.current();
        uint256 index = 0;
        NftPackageType[] memory items = new NftPackageType[](total);
        for (uint256 i = 1; i <= total; i++) {
            items[index] = _nftPackageTypes[i];
            index++;
        }
        return items;
    }
}
