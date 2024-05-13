import { ethers, hardhatArguments } from "hardhat";
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
    const subscribeId = await question("What is subscribeId?");
    const EldaruneJourney = new ExtendContract("EldaruneJourney");
    const [owner, acc1] = await ethers.getSigners();
    const eldaruneJourneyInstance = await EldaruneJourney.contractInstance(
      true
    );
    try {
      let _subscribeId = Number(subscribeId);
      let result = await eldaruneJourneyInstance.endJourney(_subscribeId);
      result = await result.wait(1);
      if (result.status === 1) {
        console.log(
          `End Journey Successfull - Running Network ${hardhatArguments.network}`
        );
      } else {
        console.log(
          `End Journey Failed - Running Network ${hardhatArguments.network}`
        );
      }
    } catch (ex) {
      console.log(
        `End Journey Failed - Running Network ${hardhatArguments.network} Error:`,
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
