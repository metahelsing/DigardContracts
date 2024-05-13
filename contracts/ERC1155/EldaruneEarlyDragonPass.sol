// contracts/EldaruneEarlyDragonPass.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./token/NTERC1155.sol";

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract EldaruneEarlyDragonPass is NTERC1155 {
    constructor()
        NTERC1155("https://cdn.digard.io/Eldarune/EarlyDragon/1.json")
    {
        tokenId = 1;
        maxMintNFT = 1111;
        remainingNFT = 1111;
        referenceBonusRatio = 5;
        saleowner = payable(msg.sender);
    }

    using MerkleProof for bytes32[];
    using Counters for Counters.Counter;
    Counters.Counter private _buyItemCounter;
    Counters.Counter private _referenceCounter;
    Counters.Counter private _referenceCodeCounter;

    bytes32 public merkleRoot;

    struct SaleProgram {
        bool whiteListEnabled;
        bool referenceEnabled;
        bool saleEnabled;
        uint256 startDate;
        uint256 endDate;
        uint256 buyAmount;
    }

    struct SaleData {
        uint256 saleId;
        address buyer;
        uint256 amount;
        uint256 time;
        uint256 nftAmount;
        string referenceCode;
    }

    struct ReferenceData {
        string referenceCode;
        address referenceAddress;
        address[] referrals;
        uint256 totalReference;
        uint256 referenceRatio;
    }

    struct ReferenceCode {
        string referenceCode;
        address referenceAddress;
    }

    uint256 private tokenId;
    uint256 private maxMintNFT;
    uint256 private remainingNFT;
    uint256 private referenceBonusRatio;
    address payable public saleowner;
    uint256 private currentSaleProgram;
    

    mapping(uint256 => SaleData) private SaleDatas;
    mapping(string => ReferenceData) private ReferenceDatas;
    mapping(uint256 => ReferenceCode) private ReferenceCodeAddresses;
    SaleProgram private _SaleProgram;

    function setSaleProgram(SaleProgram memory _SaleProgramList)
        public
        onlyOwner
    {
        _SaleProgram = _SaleProgramList;
    }

    function getCurrentSaleProgram()
        public
        view
        returns (SaleProgram[] memory)
    {
        SaleProgram[] memory items = new SaleProgram[](1);
        items[0] = _SaleProgram;
        return items;
    }

    function getSaleInformation()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (tokenId, maxMintNFT, remainingNFT);
    }

    function startSale() public onlyOwner {
        _SaleProgram.saleEnabled = true;
    }

    function pauseSale() public onlyOwner {
        _SaleProgram.saleEnabled = false;
    }

    function setMerkleRoot(bytes32 _root) public onlyOwner {
        merkleRoot = _root;
    }

    function setSaleOwner(address payable _saleOwner) public onlyOwner {
        require(msg.sender != address(0x0), "Public address is not correct");
        saleowner = _saleOwner;
    }

    function toBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function setReferenceRatio(uint256 ratio) public onlyOwner {
        referenceBonusRatio = ratio;
    }

    function setTransferEnabled(bool _transferEnabled) public onlyOwner {
        transferEnabled = _transferEnabled;
    }

    function searchReferralls(ReferenceData memory _referenceData)
        private
        view
        returns (bool)
    {
        bool isAny;
        for (uint256 i = 0; i < _referenceData.referrals.length; i++) {
            if (_referenceData.referrals[i] == msg.sender) {
                isAny = true;
            }
        }
        return isAny;
    }
    

    function getReferenceAddressByCode(string memory refCode)
        private
        view
        returns (address, bool isFind)
    {
        isFind = false;
        address addr = address(0x0);
        uint256 total = _referenceCodeCounter.current();
        for (uint256 i = 1; i <= total; i++) {
            if (keccak256(abi.encodePacked((ReferenceCodeAddresses[i].referenceCode))) == keccak256(abi.encodePacked((refCode)))) {
                addr = ReferenceCodeAddresses[i].referenceAddress;
                isFind = true;
            }
        }
        return (addr, isFind);
    }

    function getReferenceCode() public view returns (string memory rtn) {
        uint256 total = _referenceCodeCounter.current();
        for (uint256 i = 1; i <= total; i++) {
            if (ReferenceCodeAddresses[i].referenceAddress == msg.sender) {
                rtn = ReferenceCodeAddresses[i].referenceCode;
            }
        }
        return rtn;
    }

    function getReferenceCodeAddress(address addr)
        private
        view
        returns (bool isFind)
    {
        isFind = false;
        uint256 total = _referenceCodeCounter.current();
        for (uint256 i = 1; i <= total; i++) {
            if (ReferenceCodeAddresses[i].referenceAddress == addr) {
                isFind = true;
            }
        }
        return isFind;
    }

    function saleNFT(
        bytes32[] memory proof,
        uint256 amount,
        string memory myReferenceCode,
        string memory referenceCode
    ) public payable {
        SaleProgram memory currentSale = _SaleProgram;
        address nftMinter = msg.sender;
        require(remainingNFT > 0, "All nfts are exhausted.");
        require(currentSale.saleEnabled == true, "NFT sale is not active.");
        require(
            currentSale.startDate <= block.timestamp,
            "NFT sale is not active."
        );
        require(currentSale.endDate >= block.timestamp, "Sale has ended");
        require(msg.sender != address(0x0), "Public address is not correct");
        require(
            remainingNFT >= amount,
            "The amount to be purchased is greater than the remaining amount."
        );

        if (currentSale.whiteListEnabled) {
            require(
                MerkleProof.verify(proof, merkleRoot, toBytes32(msg.sender)),
                "You are not in the list"
            );
        }

        uint256 total = SafeMath.mul(amount, currentSale.buyAmount);
        require(msg.value == total, "Insufficient balance");
        _mint(nftMinter, tokenId, amount, "");
        payable(saleowner).transfer(msg.value);
        remainingNFT -= amount;

        bool isFind = getReferenceCodeAddress(msg.sender);
        if (!isFind) {
            _referenceCodeCounter.increment();
            uint256 referenceCodeId = _referenceCodeCounter.current();
            ReferenceCodeAddresses[referenceCodeId] = ReferenceCode(
                myReferenceCode,
                msg.sender
            );
        }

        if (currentSale.referenceEnabled) {
            if (ReferenceDatas[referenceCode].totalReference > 0) {
                if (
                    ReferenceDatas[referenceCode].referenceAddress != msg.sender
                ) {
                    if (!searchReferralls(ReferenceDatas[referenceCode])) {
                        if (
                            ReferenceDatas[referenceCode].totalReference < 100
                        ) {
                            ReferenceDatas[referenceCode].totalReference++;
                            address[] memory newReferences = new address[](
                                ReferenceDatas[referenceCode].totalReference
                            );

                            for (
                                uint256 i = 0;
                                i <
                                ReferenceDatas[referenceCode].referrals.length;
                                i++
                            ) {
                                newReferences[i] = ReferenceDatas[referenceCode]
                                    .referrals[i];
                            }
                            newReferences[
                                ReferenceDatas[referenceCode].totalReference - 1
                            ] = msg.sender;
                            ReferenceDatas[referenceCode]
                                .referrals = newReferences;
                        }
                    }
                }
            } else {
                address referenceAddress;
                
                (referenceAddress, isFind) = getReferenceAddressByCode(referenceCode);
                
                if (isFind) {
                    _referenceCounter.increment();
                    address[] memory newReferences = new address[](1);
                    newReferences[0] = msg.sender;

                    ReferenceDatas[referenceCode] = ReferenceData(
                        referenceCode,
                        referenceAddress,
                        newReferences,
                        1,
                        referenceBonusRatio
                    );
                }
            }
        }

        _buyItemCounter.increment();
        uint256 id = _buyItemCounter.current();

        SaleDatas[id] = SaleData(
            id,
            nftMinter,
            amount,
            block.timestamp,
            currentSale.buyAmount,
            referenceCode
        );

    }

    function fetchSaleData() public view onlyOwner returns (SaleData[] memory) {
        uint256 total = _buyItemCounter.current();

        uint256 index = 0;
        SaleData[] memory items = new SaleData[](total);
        for (uint256 i = 1; i <= total; i++) {
            items[index] = SaleDatas[i];
            index++;
        }
        return items;
    }

    function fetchReferenceData()
        public
        view
        onlyOwner
        returns (ReferenceData[] memory)
    {
        uint256 total = _referenceCodeCounter.current();
        uint256 index = 0;
        uint256 arrayTotal = _referenceCounter.current();
        ReferenceData[] memory items = new ReferenceData[](arrayTotal);
        for (uint256 i = 1; i <= total; i++) 
        {
            if(ReferenceDatas[ReferenceCodeAddresses[i].referenceCode].totalReference > 0) {
               items[index] = ReferenceDatas[ReferenceCodeAddresses[i].referenceCode];
               index++;
            }
            
        }
        return items;
    }
}
