export type Task = {
  taskGroupId: number;
  taskId: number;
  lockTime: number[];
  numberOfRepetitions: number;
  successRate: number;
};
export type Reward = {
  claimRewardContractIndex: number;
  tokenId: number;
  amount: number;
  tokenAddress: string;
};
export type RequirementNft = {
  tokenAddress: string;
  tokenIds: number[];
  amount: number;
  burnRate: number;
};
export type RequirementToken = {
  tokenAddress: string;
  amount: number;
};

export type ExtReward = {
  taskId: number;
  rewards: Reward[];
};
export type ExtRequirementNft = {
  taskId: number;
  requirementNfts: RequirementNft[];
};
export type ExtRequirementToken = {
  taskId: number;
  requirementToken: RequirementToken;
};
export type ExtRequirementTask = {
  taskId: number;
  requirementTaskIds: number[];
};
export type ExtendedTask = {
  task: Task;
  rewards: ExtReward;
  requirementNfts: ExtRequirementNft;
  requirementTokens: ExtRequirementToken;
  requirementTask?: ExtRequirementTask;
};
