import { hardhatArguments } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import { ExtendedTask, Task } from "./types/taskType";
const fs = require("fs").promises;

async function main() {
  const EldaruneJourney = new ExtendContract("EldaruneJourney");
  const eldaruneJourneyInstance = await EldaruneJourney.contractInstance(true);
  try {
    let _networkName = hardhatArguments.network;
    let taskListJSON = await fs.readFile(
      `scripts/eldarune/journey/data/taskList-${_networkName}.json`,
      "utf8"
    );
    taskListJSON = JSON.parse(taskListJSON);
    let taskList: Task[] = taskListJSON.map((f: ExtendedTask) => {
      return f.task;
    });
    console.log(taskList);
    let result = await eldaruneJourneyInstance.saveTasks(taskList, {
      gasLimit: 12000000,
    });
    result = await result.wait(1);
    if (result.status === 1) {
      console.log(
        `Save Task Successfull - Running Network ${hardhatArguments.network}`
      );
    } else {
      console.log(
        `Save Task Failed - Running Network ${hardhatArguments.network}`
      );
    }
  } catch (ex) {
    console.log(
      `Save Task Failed - Running Network ${hardhatArguments.network} Error:`,
      ex
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
