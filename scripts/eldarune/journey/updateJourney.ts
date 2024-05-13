import { hardhatArguments } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const fs = require("fs").promises;
const readline = require("readline");

async function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const question = (prompt: string) => {
    return new Promise((resolve, reject) => {
      rl.question(prompt, resolve);
    });
  };

  (async () => {
    const playerAddress = await question("What is playerAddress?");
    const taskId = await question("What is taskId?");
    const EldaruneJourney = new ExtendContract("EldaruneJourney");
    const eldaruneJourneyInstance = await EldaruneJourney.contractInstance(
      true
    );
    try {
      let result = await eldaruneJourneyInstance.updateJourney(
        String(playerAddress),
        Number(taskId)
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log(
          `Update Journey Successfull - Running Network ${hardhatArguments.network}`
        );
      } else {
        console.log(
          `Update Journey Failed - Running Network ${hardhatArguments.network}`
        );
      }
    } catch (ex) {
      console.log(
        `Update Journey Failed - Running Network ${hardhatArguments.network} Error:`,
        ex
      );
    }
    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
