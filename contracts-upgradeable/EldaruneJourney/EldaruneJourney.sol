// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "../Interfaces/IDigardERC1155Burnable.sol";
import "../Interfaces/IDigardClaim.sol";
import "../Utils/RandomNumber.sol";
import "../Utils/StakingHelper.sol";
import {Task, Reward, Subscribe, RequirementNft, RequirementToken, LockedRequirementNft} from "./libraries/LibTask.sol";
import "hardhat/console.sol";

contract EldaruneJourney is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant SAVE_MISSION_ROLE = keccak256("SAVE_MISSION_ROLE");

    struct ExtReward {
        uint256 taskId;
        Reward[] rewards;
    }

    struct ExtRequirement {
        uint256 taskId;
        ExtRequirementNFT[] requirementNfts;
    }

    struct ExtRequirementToken {
        uint256 taskId;
        RequirementToken requirementToken;
    }

    struct ExtRequirementNFT {
        address tokenAddress;
        uint256[] tokenIds;
        uint256 amount;
        uint256 burnRate;
    }

    struct ExtStartRequirementNFT {
        address tokenAddress;
        uint256 tokenId;
        uint256 amount;
    }

    struct ExtRequirementTask {
        uint256 taskId;
        uint256[] requirementTaskIds;
    }

    struct EndLockedNftResult {
        uint256 tokenId;
        uint256 burnedAmount;
        uint256 refundAmount;
        address tokenAddress;
    }

    event SaveTask(Task[] tasks);

    event SaveReward(ExtReward[] rewards);

    event SaveRequirementNft(ExtRequirement[] requirementNfts);

    event SaveRequirementToken(ExtRequirementToken[] requirementTokens);

    event SaveRequirementTask(ExtRequirementTask[] requirementTasks);

    event StartTask(
        uint256 subscribeId,
        uint256 indexed taskGroupId,
        uint256 indexed taskId,
        uint256 endTime,
        address indexed walletAddress,
        LockedRequirementNft[] lockedRequirementNfts,
        RequirementToken requirementToken
    );

    event EndTask(
        uint256 subscribeId,
        uint256 indexed taskGroupId,
        uint256 indexed taskId,
        address indexed walletAddress,
        bool isSuccess,
        EndLockedNftResult[] endLockedNftResults
    );

    using StakingHelper for uint256;
    using Randomize for Randomize.Random;
    uint256 subscribeCounter;
    Randomize.Random private _randomize;
    address private _gameTokenPoolAddress;
    address private _digardClaimAddress;

    mapping(uint256 => Task) _tasks;
    mapping(uint256 => Reward[]) _taskRewards;
    mapping(uint256 => mapping(uint256 => RequirementNft)) _taskRequirementNfts;
    mapping(uint256 => RequirementToken) _taskRequirementTokens;
    mapping(uint256 => uint256[]) _taskRequirementTasks;
    mapping(address => mapping(uint256 => Subscribe)) _taskSubscribes;
    mapping(uint256 => LockedRequirementNft[]) _subscribeLockedNfts;
    mapping(address => mapping(uint256 => uint256)) _playerTaskLength;
    mapping(address => mapping(uint256 => bool)) _playerTaskActive;
    mapping(uint256 => uint256) _missionRequirementNftTotalAmounts;

    constructor() {}

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) public returns (bytes4) {
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
    ) public returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    function initialize(
        address __gameTokenPoolAddress,
        address __digardClaimAddress
    ) public initializer {
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        _gameTokenPoolAddress = __gameTokenPoolAddress;
        _digardClaimAddress = __digardClaimAddress;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(SAVE_MISSION_ROLE, msg.sender);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function saveTasks(
        Task[] memory tasks
    ) external onlyRole(SAVE_MISSION_ROLE) {
        for (uint256 i; i < tasks.length; i++) {
            _tasks[tasks[i].taskId] = tasks[i];
        }
        emit SaveTask(tasks);
    }

    function saveRewards(
        ExtReward[] memory taskRewards
    ) external onlyRole(SAVE_MISSION_ROLE) {
        for (uint256 r; r < taskRewards.length; r++) {
            for (uint256 k; k < taskRewards[r].rewards.length; k++) {
                if (taskRewards[r].rewards[k].tokenId == 0) {
                    uint256 _rewardDecimal = IERC20MetadataUpgradeable(
                        taskRewards[r].rewards[k].tokenAddress
                    ).decimals();
                    _rewardDecimal = 10 ** uint256(_rewardDecimal);
                    taskRewards[r].rewards[k].amount =
                        taskRewards[r].rewards[k].amount *
                        _rewardDecimal;
                }
            }
        }
        emit SaveReward(taskRewards);
    }

    function saveRequirementNfts(
        ExtRequirement[] memory taskRequirementNfts
    ) external onlyRole(SAVE_MISSION_ROLE) {
        for (uint256 r; r < taskRequirementNfts.length; r++) {
            uint256 taskId = taskRequirementNfts[r].taskId;
            _missionRequirementNftTotalAmounts[taskId] = 0;
            for (
                uint256 x;
                x < taskRequirementNfts[r].requirementNfts.length;
                x++
            ) {
                for (
                    uint256 y;
                    y <
                    taskRequirementNfts[r].requirementNfts[x].tokenIds.length;
                    y++
                ) {
                    uint256 tokenId = taskRequirementNfts[r]
                        .requirementNfts[x]
                        .tokenIds[y];
                    RequirementNft memory requirementNft = RequirementNft(
                        taskRequirementNfts[r].requirementNfts[x].tokenAddress,
                        tokenId,
                        taskRequirementNfts[r].requirementNfts[x].amount,
                        taskRequirementNfts[r].requirementNfts[x].burnRate
                    );

                    _taskRequirementNfts[taskId][tokenId] = requirementNft;
                }
                _missionRequirementNftTotalAmounts[
                    taskId
                ] += taskRequirementNfts[r].requirementNfts[x].amount;
            }
        }
        emit SaveRequirementNft(taskRequirementNfts);
    }

    function saveRequirementTokens(
        ExtRequirementToken[] memory taskRequirementTokens
    ) external onlyRole(SAVE_MISSION_ROLE) {
        for (uint256 r; r < taskRequirementTokens.length; r++) {
            uint256 _rewardDecimal = IERC20MetadataUpgradeable(
                taskRequirementTokens[r].requirementToken.tokenAddress
            ).decimals();
            _rewardDecimal = 10 ** uint256(_rewardDecimal);
            _taskRequirementTokens[
                taskRequirementTokens[r].taskId
            ] = taskRequirementTokens[r].requirementToken;
        }
        emit SaveRequirementToken(taskRequirementTokens);
    }

    function saveRequirementTasks(
        ExtRequirementTask[] memory requirementTasks
    ) external onlyRole(SAVE_MISSION_ROLE) {
        require(requirementTasks.length > 0, "No requirement task");
        for (uint256 i = 0; i < requirementTasks.length; i++) {
            uint256 taskId = requirementTasks[i].taskId;
            _taskRequirementTasks[taskId] = requirementTasks[i]
                .requirementTaskIds;
        }
        emit SaveRequirementTask(requirementTasks);
    }

    function saveGameTokenPoolAddress(
        address __gameTokenPoolAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _gameTokenPoolAddress = __gameTokenPoolAddress;
    }

    function saveDigardClaimAddress(
        address __digardClaimAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _digardClaimAddress = __digardClaimAddress;
    }

    function startJourney(
        uint256 taskId,
        ExtStartRequirementNFT[] memory startRequirementNFTs
    ) public nonReentrant whenNotPaused {
        require(_tasks[taskId].taskId > 0, "Undefined task id");
        address msgSender = _msgSender();
        if (_playerTaskActive[msgSender][taskId]) {
            revert("This task is already active");
        }

        uint256 completedLength = 0;
        for (uint256 rm = 0; rm < _taskRequirementTasks[taskId].length; rm++) {
            if (_playerTaskLength[msgSender][taskId] > 0) {
                completedLength++;
            }
        }
        if (_taskRequirementTasks[taskId].length > 0) {
            require(
                completedLength == _taskRequirementTasks[taskId].length,
                "Incomplete completed task"
            );
        }

        if (_tasks[taskId].numberOfRepetitions > 0) {
            require(
                _playerTaskLength[msgSender][taskId] <
                    _tasks[taskId].numberOfRepetitions,
                "You have reached the task limit"
            );
        }
        subscribeCounter++;
        uint256 acceptedDepositAmount;
        for (uint256 i; i < startRequirementNFTs.length; i++) {
            uint256 tokenId = startRequirementNFTs[i].tokenId;
            uint256 amount = startRequirementNFTs[i].amount;
            address tokenAddress = startRequirementNFTs[i].tokenAddress;
            if (
                _taskRequirementNfts[taskId][tokenId].tokenAddress ==
                tokenAddress
            ) {
                IERC1155Upgradeable(
                    _taskRequirementNfts[taskId][tokenId].tokenAddress
                ).safeTransferFrom(
                        msgSender,
                        address(this),
                        tokenId,
                        amount,
                        msg.data
                    );
                acceptedDepositAmount += amount;
                LockedRequirementNft
                    memory lockedRequirementNft = LockedRequirementNft(
                        _taskRequirementNfts[taskId][tokenId].tokenAddress,
                        tokenId,
                        amount,
                        _taskRequirementNfts[taskId][tokenId].burnRate
                    );
                _subscribeLockedNfts[subscribeCounter].push(
                    lockedRequirementNft
                );
            }
        }
        require(
            _missionRequirementNftTotalAmounts[taskId] == acceptedDepositAmount,
            "Missing requirement balance for journey"
        );
        IERC20(_taskRequirementTokens[taskId].tokenAddress).transferFrom(
            msgSender,
            _gameTokenPoolAddress,
            _taskRequirementTokens[taskId].amount
        );
        uint256 lockDuration = StakingHelper.calculateProgramDuration(
            _tasks[taskId].lockTime
        );
        uint256 endTime = block.timestamp + lockDuration;
        _playerTaskActive[msgSender][taskId] = true;
        _playerTaskLength[msgSender][taskId]++;
        _taskSubscribes[msgSender][subscribeCounter] = Subscribe(
            subscribeCounter,
            _tasks[taskId].taskId,
            block.timestamp,
            block.number,
            true
        );
        emit StartTask(
            subscribeCounter,
            _tasks[taskId].taskGroupId,
            taskId,
            endTime,
            msgSender,
            _subscribeLockedNfts[subscribeCounter],
            _taskRequirementTokens[taskId]
        );
    }

    function endJourney(uint256 subscribeId) public nonReentrant whenNotPaused {
        require(
            _taskSubscribes[_msgSender()][subscribeId].subscribeId > 0,
            "No subscribe"
        );
        require(
            _taskSubscribes[_msgSender()][subscribeId].active,
            "No active journey"
        );
        uint256 taskId = _taskSubscribes[_msgSender()][subscribeId].taskId;
        uint256 lockDuration = StakingHelper.calculateProgramDuration(
            _tasks[taskId].lockTime
        );
        uint256 addedBlock = lockDuration / 3;
        uint256 endBlock = _taskSubscribes[_msgSender()][subscribeId]
            .startBlockNumber + addedBlock;
        if (
            block.timestamp >=
            _taskSubscribes[_msgSender()][subscribeId].startTime +
                lockDuration &&
            block.number >= endBlock
        ) {
            uint256 successNumber = _randomize.newNonZeroRandomNumber(100);
            bool isSuccess = successNumber <= _tasks[taskId].successRate;
            if (isSuccess) {
                Reward[] memory rewards = _taskRewards[taskId];
                for (uint256 r = 0; r < rewards.length; r++) {
                    if (rewards[r].tokenId == 0) {
                        IDigardClaim(_digardClaimAddress).addPlayerToken(
                            _msgSender(),
                            rewards[r].amount
                        );
                    } else {
                        IDigardClaim(_digardClaimAddress).addPlayerClaimNft(
                            _msgSender(),
                            rewards[r].claimRewardContractIndex,
                            rewards[r].tokenId,
                            rewards[r].amount
                        );
                    }
                }
            }

            EndLockedNftResult[]
                memory endLockedNftResults = new EndLockedNftResult[](
                    _subscribeLockedNfts[subscribeId].length
                );

            for (
                uint256 l = 0;
                l < _subscribeLockedNfts[subscribeId].length;
                l++
            ) {
                uint256 burnedAmount;
                uint256 refundAmount;
                for (
                    uint256 k = 0;
                    k < _subscribeLockedNfts[subscribeId][l].amount;
                    k++
                ) {
                    uint256 randomizeNumber = _randomize.newNonZeroRandomNumber(
                        100
                    );
                    bool isBurn = randomizeNumber <=
                        _subscribeLockedNfts[subscribeId][l].burnRate;
                    if (isBurn) burnedAmount++;
                    else refundAmount++;
                }

                if (burnedAmount > 0) {
                    IDigardERC1155Burnable(
                        _subscribeLockedNfts[subscribeId][l].tokenAddress
                    ).burn(
                            address(this),
                            _subscribeLockedNfts[subscribeId][l].tokenId,
                            burnedAmount
                        );
                }

                if (refundAmount > 0) {
                    IERC1155Upgradeable(
                        _subscribeLockedNfts[subscribeId][l].tokenAddress
                    ).safeTransferFrom(
                            address(this),
                            _msgSender(),
                            _subscribeLockedNfts[subscribeId][l].tokenId,
                            refundAmount,
                            msg.data
                        );
                }
                endLockedNftResults[l] = EndLockedNftResult(
                    _subscribeLockedNfts[subscribeId][l].tokenId,
                    burnedAmount,
                    refundAmount,
                    _subscribeLockedNfts[subscribeId][l].tokenAddress
                );
            }
            _playerTaskActive[_msgSender()][taskId] = false;
            _taskSubscribes[_msgSender()][subscribeId].active = false;

            emit EndTask(
                subscribeId,
                _tasks[taskId].taskGroupId,
                taskId,
                _msgSender(),
                isSuccess,
                endLockedNftResults
            );
        }
    }

    function updateJourney(
        address playerAddress,
        uint256 taskId
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _playerTaskActive[playerAddress][taskId] = false;
    }

    function getTaskRequirementTask(
        uint256 taskId,
        ExtStartRequirementNFT[] memory startRequirementNFTs
    ) public view returns (uint256, uint256) {
        address msgSender = _msgSender();
        uint256 acceptedDepositAmount;
        for (uint256 i; i < startRequirementNFTs.length; i++) {
            uint256 tokenId = startRequirementNFTs[i].tokenId;
            uint256 amount = startRequirementNFTs[i].amount;
            address tokenAddress = startRequirementNFTs[i].tokenAddress;
            if (
                _taskRequirementNfts[taskId][tokenId].tokenAddress ==
                tokenAddress
            ) {
                acceptedDepositAmount += amount;
            }
        }

        return (
            _missionRequirementNftTotalAmounts[taskId],
            acceptedDepositAmount
        );
    }
}
