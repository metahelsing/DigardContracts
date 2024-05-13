import { hardhatArguments } from "hardhat";
//const eldaruneUtilityCollectionWhiteList = require('../../../configs/eldaruneUtilityCollectionWhiteList.json');

export interface StakingProgram {
  stakingProgramId: number;
  tokenId: number;
  stakingTimeDuration: Array<number>;
  stakingReward: StakingReward;
}

export interface StakingReward {
  rewardTokenId: number;
  rewardNftContractIndex: number;
  rewardAmount: number;
  rewardName: string;
}

export interface StakingSubscribe {
  stakingSubscribeId: number;
  stakingProgramId: number;
  stakingStartDate: number;
  stakingEndDate: number;
  tokenId: BigInt;
  stakerAddress: string;
}

export enum tokenIds {
  Empty,
  Common,
  UnCommon,
  Rare,
  Epic,
  Legendary,
  Ancient,
  Unique,
}

export enum StakingRewards {
  Empty,
  UncommonOathStone,
  RareOathStone,
  EpicOathStone,
  LegendaryOathStone,
}

export function EldaruneUtilityStakingFixture() {
  let _networkName = hardhatArguments.network;

  let stakingPrograms: Array<StakingProgram> = [
    {
      stakingProgramId: 1,
      tokenId: 1,
      stakingTimeDuration: [40, 0, 0],
      stakingReward: {
        rewardTokenId: 5,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Uncommon Oathstone",
      },
    },
    {
      stakingProgramId: 2,
      tokenId: 2,
      stakingTimeDuration: [30, 0, 0],
      stakingReward: {
        rewardTokenId: 5,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Uncommon Oathstone",
      },
    },
    {
      stakingProgramId: 3,
      tokenId: 3,
      stakingTimeDuration: [20, 0, 0],
      stakingReward: {
        rewardTokenId: 5,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Uncommon Oathstone",
      },
    },
    {
      stakingProgramId: 4,
      tokenId: 3,
      stakingTimeDuration: [30, 0, 0],
      stakingReward: {
        rewardTokenId: 6,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Rare Oathstone",
      },
    },
    {
      stakingProgramId: 5,
      tokenId: tokenIds.Epic,
      stakingTimeDuration: [15, 0, 0],
      stakingReward: {
        rewardTokenId: 5,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Uncommon Oathstone",
      },
    },
    {
      stakingProgramId: 6,
      tokenId: tokenIds.Epic,
      stakingTimeDuration: [20, 0, 0],
      stakingReward: {
        rewardTokenId: 6,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Rare Oathstone",
      },
    },
    {
      stakingProgramId: 7,
      tokenId: tokenIds.Epic,
      stakingTimeDuration: [30, 0, 0],
      stakingReward: {
        rewardTokenId: 7,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Epic Oathstone",
      },
    },
    {
      stakingProgramId: 8,
      tokenId: tokenIds.Legendary,
      stakingTimeDuration: [10, 0, 0],
      stakingReward: {
        rewardTokenId: 5,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Uncommon Oathstone",
      },
    },
    {
      stakingProgramId: 9,
      tokenId: tokenIds.Legendary,
      stakingTimeDuration: [15, 0, 0],
      stakingReward: {
        rewardTokenId: 6,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Rare Oathstone",
      },
    },
    {
      stakingProgramId: 10,
      tokenId: tokenIds.Legendary,
      stakingTimeDuration: [20, 0, 0],
      stakingReward: {
        rewardTokenId: 7,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Epic Oathstone",
      },
    },
    {
      stakingProgramId: 11,
      tokenId: tokenIds.Legendary,
      stakingTimeDuration: [30, 0, 0],
      stakingReward: {
        rewardTokenId: 8,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Legendary Oathstone",
      },
    },
    {
      stakingProgramId: 12,
      tokenId: tokenIds.Ancient,
      stakingTimeDuration: [8, 0, 0],
      stakingReward: {
        rewardTokenId: 5,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Uncommon Oathstone",
      },
    },
    {
      stakingProgramId: 13,
      tokenId: tokenIds.Ancient,
      stakingTimeDuration: [12, 0, 0],
      stakingReward: {
        rewardTokenId: 6,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Rare Oathstone",
      },
    },
    {
      stakingProgramId: 14,
      tokenId: tokenIds.Ancient,
      stakingTimeDuration: [16, 0, 0],
      stakingReward: {
        rewardTokenId: 7,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Epic Oathstone",
      },
    },
    {
      stakingProgramId: 15,
      tokenId: tokenIds.Ancient,
      stakingTimeDuration: [20, 0, 0],
      stakingReward: {
        rewardTokenId: 8,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Legendary Oathstone",
      },
    },
    {
      stakingProgramId: 16,
      tokenId: tokenIds.Unique,
      stakingTimeDuration: [4, 0, 0],
      stakingReward: {
        rewardTokenId: 5,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Uncommon Oathstone",
      },
    },
    {
      stakingProgramId: 17,
      tokenId: tokenIds.Unique,
      stakingTimeDuration: [6, 0, 0],
      stakingReward: {
        rewardTokenId: 6,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Rare Oathstone",
      },
    },
    {
      stakingProgramId: 18,
      tokenId: tokenIds.Unique,
      stakingTimeDuration: [8, 0, 0],
      stakingReward: {
        rewardTokenId: 7,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Epic Oathstone",
      },
    },
    {
      stakingProgramId: 19,
      tokenId: tokenIds.Unique,
      stakingTimeDuration: [10, 0, 0],
      stakingReward: {
        rewardTokenId: 8,
        rewardNftContractIndex: 1,
        rewardAmount: 1,
        rewardName: "Legendary Oathstone",
      },
    },
  ];
  let blockGeneratedSeconds = 3;
  //Testnet ise farklı programlar
  switch (_networkName) {
    case "goerli":
    case "bscTestnet":
      stakingPrograms = [
        {
          stakingProgramId: 1,
          tokenId: tokenIds.Common,
          stakingTimeDuration: [0, 0, 2],
          stakingReward: {
            rewardTokenId: 5,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Uncommon Oathstone",
          },
        },
        {
          stakingProgramId: 2,
          tokenId: tokenIds.UnCommon,
          stakingTimeDuration: [0, 0, 2],
          stakingReward: {
            rewardTokenId: 5,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Uncommon Oathstone",
          },
        },
        {
          stakingProgramId: 3,
          tokenId: tokenIds.Rare,
          stakingTimeDuration: [0, 0, 2],
          stakingReward: {
            rewardTokenId: 5,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Uncommon Oathstone",
          },
        },
        {
          stakingProgramId: 4,
          tokenId: tokenIds.Rare,
          stakingTimeDuration: [0, 0, 5],
          stakingReward: {
            rewardTokenId: 6,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Rare Oathstone",
          },
        },
        {
          stakingProgramId: 5,
          tokenId: tokenIds.Epic,
          stakingTimeDuration: [0, 0, 2],
          stakingReward: {
            rewardTokenId: 5,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Uncommon Oathstone",
          },
        },
        {
          stakingProgramId: 6,
          tokenId: tokenIds.Epic,
          stakingTimeDuration: [0, 0, 5],
          stakingReward: {
            rewardTokenId: 6,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Rare Oathstone",
          },
        },
        {
          stakingProgramId: 7,
          tokenId: tokenIds.Epic,
          stakingTimeDuration: [0, 0, 10],
          stakingReward: {
            rewardTokenId: 7,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Epic Oathstone",
          },
        },
        {
          stakingProgramId: 8,
          tokenId: tokenIds.Legendary,
          stakingTimeDuration: [0, 0, 2],
          stakingReward: {
            rewardTokenId: 5,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Uncommon Oathstone",
          },
        },
        {
          stakingProgramId: 9,
          tokenId: tokenIds.Legendary,
          stakingTimeDuration: [0, 0, 5],
          stakingReward: {
            rewardTokenId: 6,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Rare Oathstone",
          },
        },
        {
          stakingProgramId: 10,
          tokenId: tokenIds.Legendary,
          stakingTimeDuration: [0, 0, 10],
          stakingReward: {
            rewardTokenId: 7,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Epic Oathstone",
          },
        },
        {
          stakingProgramId: 11,
          tokenId: tokenIds.Legendary,
          stakingTimeDuration: [0, 0, 15],
          stakingReward: {
            rewardTokenId: 8,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Legendary Oathstone",
          },
        },
        {
          stakingProgramId: 12,
          tokenId: tokenIds.Ancient,
          stakingTimeDuration: [0, 0, 2],
          stakingReward: {
            rewardTokenId: 5,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Uncommon Oathstone",
          },
        },
        {
          stakingProgramId: 13,
          tokenId: tokenIds.Ancient,
          stakingTimeDuration: [0, 0, 5],
          stakingReward: {
            rewardTokenId: 6,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Rare Oathstone",
          },
        },
        {
          stakingProgramId: 14,
          tokenId: tokenIds.Ancient,
          stakingTimeDuration: [0, 0, 10],
          stakingReward: {
            rewardTokenId: 7,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Epic Oathstone",
          },
        },
        {
          stakingProgramId: 15,
          tokenId: tokenIds.Ancient,
          stakingTimeDuration: [0, 0, 15],
          stakingReward: {
            rewardTokenId: 8,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Legendary Oathstone",
          },
        },
        {
          stakingProgramId: 16,
          tokenId: tokenIds.Unique,
          stakingTimeDuration: [0, 0, 5],
          stakingReward: {
            rewardTokenId: 5,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Uncommon Oathstone",
          },
        },
        {
          stakingProgramId: 17,
          tokenId: tokenIds.Unique,
          stakingTimeDuration: [0, 0, 10],
          stakingReward: {
            rewardTokenId: 6,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Rare Oathstone",
          },
        },
        {
          stakingProgramId: 18,
          tokenId: tokenIds.Unique,
          stakingTimeDuration: [0, 0, 15],
          stakingReward: {
            rewardTokenId: 7,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Epic Oathstone",
          },
        },
        {
          stakingProgramId: 19,
          tokenId: tokenIds.Unique,
          stakingTimeDuration: [0, 0, 20],
          stakingReward: {
            rewardTokenId: 8,
            rewardNftContractIndex: 1,
            rewardAmount: 1,
            rewardName: "Legendary Oathstone",
          },
        },
      ];
      blockGeneratedSeconds = 15;
      break;
  }

  //   stakingPrograms.map((item, index) => {
  //     let secondTotal = 0;
  //     item.stakingTimeDuration.forEach((time, timeIndex) => {
  //       if (timeIndex == 0) {
  //         secondTotal += time * 24 * 60 * 60;
  //       }
  //       if (timeIndex == 1) {
  //         secondTotal += time * 60 * 60;
  //       }
  //       if (timeIndex == 2) {
  //         secondTotal += time * 60;
  //       }
  //     });
  //     item.stakingBlockWaitSize = Math.ceil(secondTotal / blockGeneratedSeconds);
  //   });
  //console.log(stakingPrograms);
  return { stakingPrograms };
}
