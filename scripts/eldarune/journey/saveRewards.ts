import { hardhatArguments } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import { ExtReward, ExtendedTask, Task } from "./types/taskType";
const fs = require("fs").promises;

async function main() {
  const EldaruneJourney = new ExtendContract("EldaruneJourney");
  const eldaruneJourneyInstance = await EldaruneJourney.contractInstance(true);
  try {
    let _networkName = hardhatArguments.network;
    let rewardListJSON = await fs.readFile(
      `scripts/eldarune/journey/data/taskList-${_networkName}.json`,
      "utf8"
    );
    rewardListJSON = JSON.parse(rewardListJSON);
    let rewardList: ExtReward[] = rewardListJSON.map((f: ExtendedTask) => {
      return f.rewards;
    });

    let result = await eldaruneJourneyInstance.saveRewards(rewardList, {
      gasLimit: 12000000,
    });

    result = await result.wait(1);
    if (result.status === 1) {
      console.log(
        `Save Reward Successfull - Running Network ${hardhatArguments.network}`
      );
    } else {
      console.log(
        `Save Reward Failed - Running Network ${hardhatArguments.network}`
      );
    }
  } catch (ex) {
    console.log(
      `Save Reward Failed - Running Network ${hardhatArguments.network} Error:`,
      ex
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
