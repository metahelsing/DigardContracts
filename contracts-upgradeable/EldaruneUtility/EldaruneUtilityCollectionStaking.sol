// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "../Interfaces/IDigardERC1155Upgradeable.sol";
import "../Interfaces/IDigardERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../Interfaces/IDigardClaim.sol";
import "../Utils/StakingHelper.sol";
import "hardhat/console.sol";

contract EldaruneUtilityCollectionStaking is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    IDigardERC1155ReceiverUpgradeable
{
    using StakingHelper for uint256;

    bytes32 public constant PROGRAM_MODIFIER_ROLE =
        keccak256("PROGRAM_MODIFIER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    address _utilityAddress;
    uint256 _stakingProgramId;
    uint256 _stakingSubscribeId;
    IDigardClaim _digardClaim;

    struct StakingProgram {
        uint256 stakingProgramId;
        uint256 tokenId;
        uint[3] stakingTimeDuration;
        StakingReward stakingReward;
    }

    struct StakingReward {
        uint256 rewardTokenId;
        uint256 rewardNftContractIndex;
        uint256 rewardAmount;
        string rewardName;
    }

    struct StakingInformation {
        uint256 stakingSubscribeId;
        uint256 stakingProgramId;
        uint256 tokenId;
        uint256 amount;
        uint256 startTime;
        bool active;
    }

    event SaveStakingProgram(
        uint256 stakingProgramId,
        uint256 indexed tokenId,
        uint[3] stakingTimeDuration,
        uint256 rewardTokenId,
        uint256 rewardAmount,
        string rewardName,
        address rewardNftContract
    );

    event Stake(
        uint256 stakingSubscribeId,
        uint256 indexed stakingProgramId,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 startDate,
        uint256 endDate,
        address indexed stakeByAddress
    );

    event Unstake(
        uint256 stakingSubscribeId,
        address stakeByAddress,
        StakingReward stakingReward
    );

    event SuspiciousStake(uint256 stakingSubscribeId, bool active);

    event JoinHoldEarn(uint256 tokenId, uint256 balance, address sender);

    event HoldEarnEnabled(bool active);

    mapping(address => uint256[]) _addressSubscriceIds;
    mapping(uint256 => StakingProgram) _stakingPrograms;
    mapping(uint256 => StakingInformation) _stakingSubscribes;
    mapping(address => mapping(uint256 => uint256)) _holdEarns;
    bool private _holdEarnActive = false;

    constructor() {}

    function initialize(
        address utilityAddress,
        address digardClaim
    ) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PROGRAM_MODIFIER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _utilityAddress = utilityAddress;
        _digardClaim = IDigardClaim(digardClaim);
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

    function saveStakingPrograms(
        StakingProgram[] memory stakingPrograms
    ) external onlyRole(PROGRAM_MODIFIER_ROLE) {
        require(stakingPrograms.length > 0, "No staking programs");
        for (uint256 i = 0; i < stakingPrograms.length; i++) {
            uint256 stakingProgramId = stakingPrograms[i].stakingProgramId;
            uint256 rewardNftContractIndex = stakingPrograms[i]
                .stakingReward
                .rewardNftContractIndex;
            address rewardNftContract = _digardClaim.getRewardContractByIndex(
                rewardNftContractIndex
            );
            StakingReward memory stakingReward = StakingReward(
                stakingPrograms[i].stakingReward.rewardTokenId,
                stakingPrograms[i].stakingReward.rewardNftContractIndex,
                stakingPrograms[i].stakingReward.rewardAmount,
                stakingPrograms[i].stakingReward.rewardName
            );
            _stakingPrograms[stakingProgramId] = StakingProgram(
                stakingProgramId,
                stakingPrograms[i].tokenId,
                stakingPrograms[i].stakingTimeDuration,
                stakingReward
            );

            emit SaveStakingProgram(
                stakingProgramId,
                stakingPrograms[i].tokenId,
                stakingPrograms[i].stakingTimeDuration,
                stakingReward.rewardTokenId,
                stakingReward.rewardAmount,
                stakingReward.rewardName,
                rewardNftContract
            );
        }
    }

    function setUtilityAddress(
        address utilityAddress
    ) external onlyRole(PROGRAM_MODIFIER_ROLE) {
        _utilityAddress = utilityAddress;
    }

    function setClaimAddress(
        address digardClaimAddress
    ) external onlyRole(PROGRAM_MODIFIER_ROLE) {
        _digardClaim = IDigardClaim(digardClaimAddress);
    }

    function stakeUtility(
        uint256 tokenId,
        uint256 amount,
        uint256 stakingProgramId
    ) external {
        require(tokenId > 0, "No staking utility nfts");
        require(
            _stakingPrograms[stakingProgramId].stakingProgramId > 0,
            "Undefined staking program"
        );
        require(
            tokenId == _stakingPrograms[stakingProgramId].tokenId,
            "The token id does not match the staking program"
        );
        IDigardERC1155Upgradeable(_utilityAddress).safeTransferFrom(
            _msgSender(),
            address(this),
            tokenId,
            amount,
            msg.data
        );
        _stakingSubscribeId++;
        _stakingSubscribes[_stakingSubscribeId] = StakingInformation(
            _stakingSubscribeId,
            stakingProgramId,
            tokenId,
            amount,
            block.timestamp,
            true
        );
        _addressSubscriceIds[_msgSender()].push(_stakingSubscribeId);

        uint256 programDuration = StakingHelper.calculateProgramDuration(
            _stakingPrograms[stakingProgramId].stakingTimeDuration
        );
        uint256 endDate = block.timestamp + programDuration;
        emit Stake(
            _stakingSubscribeId,
            stakingProgramId,
            tokenId,
            amount,
            block.timestamp,
            endDate,
            _msgSender()
        );
    }

    function unStakeBulkUtility() external {
        uint256[] memory _activeSubscribeIds = _addressSubscriceIds[
            _msgSender()
        ];
        for (uint256 i = 0; i < _activeSubscribeIds.length; i++) {
            uint256 _subscribeId = _activeSubscribeIds[i];
            if (_stakingSubscribes[_subscribeId].active) {
                StakingInformation
                    memory _stakingInformation = _stakingSubscribes[
                        _subscribeId
                    ];

                uint[3] memory stakingTimeDuration = _stakingPrograms[
                    _stakingInformation.stakingProgramId
                ].stakingTimeDuration;

                uint256 programDuration = StakingHelper
                    .calculateProgramDuration(stakingTimeDuration);
                uint256 endTime = _stakingInformation.startTime +
                    programDuration;
                if (_stakingInformation.active && block.timestamp >= endTime) {
                    uint256 rewardNftContractIndex = _stakingPrograms[
                        _stakingInformation.stakingProgramId
                    ].stakingReward.rewardNftContractIndex;
                    uint256 rewardTokenId = _stakingPrograms[
                        _stakingInformation.stakingProgramId
                    ].stakingReward.rewardTokenId;
                    uint256 rewardAmount = _stakingPrograms[
                        _stakingInformation.stakingProgramId
                    ].stakingReward.rewardAmount;
                    _stakingInformation.active = false;
                    _digardClaim.addPlayerClaimNft(
                        _msgSender(),
                        rewardNftContractIndex,
                        rewardTokenId,
                        rewardAmount * _stakingInformation.amount
                    );
                    IDigardERC1155Upgradeable(_utilityAddress).safeTransferFrom(
                            address(this),
                            _msgSender(),
                            _stakingInformation.tokenId,
                            _stakingInformation.amount,
                            msg.data
                        );
                    delete _addressSubscriceIds[_msgSender()][i];
                    emit Unstake(
                        _stakingInformation.stakingSubscribeId,
                        _msgSender(),
                        _stakingPrograms[_stakingInformation.stakingProgramId]
                            .stakingReward
                    );
                }
            }
        }
    }

    function joinHoldEarn(uint256 tokenId) public {
        // uint256 balance = IDigardERC1155Upgradeable(_utilityAddress).balanceOf(
        //     _msgSender(),
        //     tokenId
        // );
        // require(balance > 0, "No utility balance");
        // _holdEarns[_msgSen der()][tokenId] = balance;
        // emit JoinHoldEarn(tokenId, balance, _msgSender());
    }

    function suspiciousTransactionFrozen(
        uint256[] memory _activeSubscribeIds
    ) external onlyRole(PROGRAM_MODIFIER_ROLE) {
        for (uint256 i = 0; i < _activeSubscribeIds.length; i++) {
            uint256 _subscribeId = _activeSubscribeIds[i];
            _stakingSubscribes[_subscribeId].active = false;

            emit SuspiciousStake(_subscribeId, false);
        }
    }

    function getAddressActiveStakingSubscribe()
        public
        view
        returns (uint256[] memory)
    {
        return _addressSubscriceIds[_msgSender()];
    }
}
