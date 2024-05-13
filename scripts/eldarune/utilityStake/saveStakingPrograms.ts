import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import { EldaruneUtilityStakingFixture } from "./data/eldaruneUtilityStakeData";

async function main() {
  const [owner] = await ethers.getSigners();
  const { stakingPrograms } = EldaruneUtilityStakingFixture();

  const eldaruneUtilityCollectionStaking = new ExtendContract(
    "EldaruneUtilityCollectionStaking"
  );
  const eldaruneUtilityStakingInstance =
    await eldaruneUtilityCollectionStaking.contractInstance(true);
  try {
    let _stakingPrograms = stakingPrograms.slice(0, 5);
    let result = await eldaruneUtilityStakingInstance.saveStakingPrograms(
      stakingPrograms,
      { gasLimit: 12000000 }
    );
    result = await result.wait(1);
    if (result.status === 1) {
      console.log(
        "Successfully  ----------------------------------------------------------->"
      );
    }
  } catch (ex: any) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
