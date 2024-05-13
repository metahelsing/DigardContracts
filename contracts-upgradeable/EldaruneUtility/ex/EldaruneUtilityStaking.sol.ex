// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../Utils/CountersUpgradeable.sol";
import "./interfaces/IEldaruneUtilityCollection.sol";
import "../Utils/StakingHelper.sol";
import "hardhat/console.sol";

contract EldaruneUtilityStaking is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using StakingHelper for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _stakingSubscribeCounter;

    struct StakingProgram {
        uint stakingProgramId;
        uint stakingLevel;
        uint[3] stakingTimeDuration;
        uint rewardId; //1-4
        string rewardName;
    }

    struct StakingSubscribe {
        uint stakingSubscribeId;
        uint stakingProgramId;
        uint256 stakingStartDate;
        uint256 stakingEndDate;
        uint256 tokenId;
        address stakerAddress;
    }

    struct StakingReward {
        uint rewardId;
        uint256 count;
    }

    event StakingProgramEvent(
        uint indexed stakingProgramId,
        uint indexed stakingLevel,
        uint[3] stakingTimeDuration,
        uint indexed rewardId,
        string rewardName
    );

    event StakingSubscribeEvent(
        uint stakingSubscribeId,
        uint stakingProgramId,
        uint256 stakingStartDate,
        uint256 stakingEndDate,
        uint256 tokenId,
        address stakerAddress
    );

    event StakingUnSubscribeEvent(uint stakingSubscribeId);

    event StakingRewardEvent(uint rewardId, address awardAddress);

    mapping(uint => StakingProgram) private _stakingPrograms;
    mapping(uint256 => StakingSubscribe) private _stakingSubscribes;
    mapping(uint256 => bool) private _stakingTokenIds;
    mapping(address => StakingReward[]) private _stakingRewards;

    uint _stakingProgramCounter;
    address _utilityBoxContractAddress;
    address _utilityUpgradeContractAddress;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        // Transfer is allowed
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override {}

    function initialize(
        address __utilityBoxContractAddress,
        address __utilityUpgradeContractAddress,
        StakingProgram[] memory __stakingPrograms
    ) public initializer {
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        _utilityBoxContractAddress = __utilityBoxContractAddress;
        _utilityUpgradeContractAddress = __utilityUpgradeContractAddress;
        saveStakingProgram(__stakingPrograms);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function saveStakingProgram(
        StakingProgram[] memory __stakingPrograms
    ) public onlyOwner {
        require(__stakingPrograms.length > 0, "Staking program is null");
        for (uint i = 0; i < __stakingPrograms.length; i++) {
            uint stakingProgramId = __stakingPrograms[i].stakingProgramId;
            if (_stakingPrograms[stakingProgramId].stakingProgramId == 0) {
                _stakingProgramCounter++;
            }
            _stakingPrograms[stakingProgramId] = StakingProgram(
                stakingProgramId,
                __stakingPrograms[i].stakingLevel,
                __stakingPrograms[i].stakingTimeDuration,
                __stakingPrograms[i].rewardId,
                __stakingPrograms[i].rewardName
            );

            emit StakingProgramEvent(
                stakingProgramId,
                __stakingPrograms[i].stakingLevel,
                __stakingPrograms[i].stakingTimeDuration,
                __stakingPrograms[i].rewardId,
                __stakingPrograms[i].rewardName
            );
        }
    }

    function getStakingProgramsByTokenId(
        uint256 _tokenId
    ) public view returns (StakingProgram[] memory) {
        StakingProgram[] memory results;
        uint index;
        uint itemLevel = IEldaruneUtilityCollection(
            _utilityUpgradeContractAddress
        ).getTokenLevelByTokenId(_tokenId);
        if (itemLevel > 0) {
            for (uint i = 0; i < _stakingProgramCounter; i++) {
                if (itemLevel == _stakingPrograms[i].stakingLevel) {
                    index++;
                    results[index] = _stakingPrograms[i];
                }
            }
        }
        return results;
    }

    function stakeSubscribe(
        uint256[] memory _tokenIds,
        uint _stakingProgramId
    ) public nonReentrant whenNotPaused {
        require(_tokenIds.length > 0, "Undefined tokenIds");
        require(
            _stakingPrograms[_stakingProgramId].stakingProgramId > 0,
            "Undefined staking program"
        );

        require(
            IERC721Upgradeable(_utilityBoxContractAddress).isApprovedForAll(
                _msgSender(),
                address(this)
            ),
            "For the staking contract, transfer approval must be given for the utility nft balance"
        );

        uint256 programDuration = StakingHelper.calculateProgramDuration(
            _stakingPrograms[_stakingProgramId].stakingTimeDuration
        );
        uint256 stakingStartDate = block.timestamp;
        uint256 stakingEndDate = SafeMathUpgradeable.add(
            stakingStartDate,
            programDuration
        );

        for (uint i = 0; i < _tokenIds.length; i++) {
            uint _tokenId = _tokenIds[i];
           
            address ownerOf = IERC721Upgradeable(_utilityBoxContractAddress)
                .ownerOf(_tokenId);

            require(
                ownerOf == _msgSender(),
                "Ownership of the nft is required for the upgrade"
            );

            uint itemLevel = IEldaruneUtilityCollection(
                _utilityUpgradeContractAddress
            ).getTokenLevelByTokenId(_tokenId);
            require(
                _stakingPrograms[_stakingProgramId].stakingLevel == itemLevel,
                "The rarity that nft has is incompatible with the staking program rarity"
            );
            _stakingSubscribeCounter.increment();

            uint256 stakingSubscriberId = _stakingSubscribeCounter.current();

            IERC721Upgradeable(_utilityBoxContractAddress).safeTransferFrom(
                _msgSender(),
                address(this),
                _tokenId
            );

            _stakingSubscribes[stakingSubscriberId] = StakingSubscribe(
                stakingSubscriberId,
                _stakingProgramId,
                stakingStartDate,
                stakingEndDate,
                _tokenId,
                _msgSender()
            );

            _stakingTokenIds[_tokenId] = true;

            emit StakingSubscribeEvent(
                stakingSubscriberId,
                _stakingProgramId,
                stakingStartDate,
                stakingEndDate,
                _tokenId,
                _msgSender()
            );
        }
    }

    function unStakeSubscribe(
        uint256 _stakingSubscribeId
    ) public nonReentrant whenNotPaused {
        require(
            _stakingSubscribes[_stakingSubscribeId].stakingSubscribeId > 0,
            "Undefined Staking Subscribe"
        );

        require(
            _stakingSubscribes[_stakingSubscribeId].stakerAddress ==
                _msgSender(),
            "Invalid Staker Address"
        );

        require(
            _stakingSubscribes[_stakingSubscribeId].stakingEndDate <
                block.timestamp,
            "Staking subscription cannot be terminated before the staking period is completed"
        );

        bool existRewardFlag;
        address stakerAddress = _msgSender();
        StakingProgram memory stakingProgram = _stakingPrograms[
            _stakingSubscribes[_stakingSubscribeId].stakingProgramId
        ];
        
        if (_stakingRewards[stakerAddress].length > 0) {
            for (uint i = 0; i < _stakingRewards[stakerAddress].length; i++) {
                if (
                    _stakingRewards[stakerAddress][i].rewardId ==
                    stakingProgram.rewardId
                ) {
                    _stakingRewards[stakerAddress][i].count++;
                    existRewardFlag = true;
                }
            }
        }
        if (!existRewardFlag) {
            _stakingRewards[stakerAddress].push(
                StakingReward(stakingProgram.rewardId, 1)
            );
        }

        _stakingTokenIds[_stakingSubscribes[_stakingSubscribeId].tokenId] == false;

        IERC721Upgradeable(_utilityBoxContractAddress).safeTransferFrom(
            address(this),
            stakerAddress,
            _stakingSubscribes[_stakingSubscribeId].tokenId
        );

        emit StakingUnSubscribeEvent(_stakingSubscribeId);

        emit StakingRewardEvent(stakingProgram.rewardId, stakerAddress);
    }
}
