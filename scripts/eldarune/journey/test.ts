import { ethers, hardhatArguments } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const fs = require("fs").promises;
async function main() {
  const EldaToken = new ExtendContract("ELDAToken");
  const eldaTokenAddress = await EldaToken.deploy();

  const ELDAPool = new ExtendContract("ELDAPool1");
  const eLDAPool = await ELDAPool.deployUpgradeable([eldaTokenAddress]);

  const PoolManager = new ExtendContract("EldaPoolManager");
  const poolManagerAddress = await PoolManager.deployUpgradeable([
    eldaTokenAddress,
    [{ poolAddress: eLDAPool, enabled: true }],
  ]);

  const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
  const eldaruneGameCollectionAddress =
    await EldaruneGameCollection.deployUpgradeable([]);
  const EldaruneJourney = new ExtendContract("EldaruneJourney");

  await EldaruneJourney.deployUpgradeable([
    eldaTokenAddress,
    poolManagerAddress,
  ]);
  const eldaruneStakeGameInstance = await EldaruneJourney.contractInstance(
    true
  );
  try {
    let missionList = await fs.readFile(
      `scripts/eldarune/stakeGame/data/missionList-hardhat.json`,
      "utf8"
    );
    missionList = JSON.parse(missionList);
    for (let i = 0; i < missionList.length; i++) {
      for (let r = 0; r < missionList[i].rewards.length; r++) {
        if (missionList[i].rewards[r].tokenId != "0") {
          missionList[i].rewards[r].tokenAddress =
            eldaruneGameCollectionAddress;
        } else missionList[i].rewards[r].tokenAddress = eldaTokenAddress;
      }
      for (let r = 0; r < missionList[i].requirements.length; r++) {
        if (missionList[i].requirements[r].tokenId != "0") {
          missionList[i].requirements[r].tokenAddress =
            eldaruneGameCollectionAddress;
        } else missionList[i].requirements[r].tokenAddress = eldaTokenAddress;
      }
    }
    console.log(eldaTokenAddress);
    let result = await eldaruneStakeGameInstance.saveMissions(missionList);
    result = await result.wait(1);
    if (result.status === 1) {
      console.log(
        `Save Mission Successfull - Running Network ${hardhatArguments.network}`
      );
      result = await eldaruneStakeGameInstance.startMission(1);
      result = await result.wait(1);
      if (result.status === 1) {
        console.log(
          `Start Mission Successfull - Running Network ${hardhatArguments.network}`
        );
      } else {
        console.log(
          `Start Mission Failed - Running Network ${hardhatArguments.network}`
        );
        console.log(result);
      }
    } else {
      console.log(
        `Save Mission Failed - Running Network ${hardhatArguments.network}`
      );
    }
  } catch (ex) {
    console.log(
      `Save Mission Failed - Running Network ${hardhatArguments.network} Error:`,
      ex
    );
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
