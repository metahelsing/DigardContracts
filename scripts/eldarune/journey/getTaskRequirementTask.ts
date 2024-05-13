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
    const taskId = await question("What is task?");
    const [owner, acc1] = await ethers.getSigners();
    const EldaruneJourney = new ExtendContract("EldaruneJourney");
    const eldaruneJourneyInstance = await EldaruneJourney.contractInstance(
      true
    );
    try {
      let _taskId = Number(taskId);
      const extStartRequirementNFTs = [
        {
          tokenAddress: "0x51d54dc3b9ebdD107660055841334893370a1a5b",
          tokenId: "1000",
          amount: "1",
        },
        {
          tokenAddress: "0x51d54dc3b9ebdD107660055841334893370a1a5b",
          tokenId: "1010",
          amount: "2",
        },
      ];
      let result = await eldaruneJourneyInstance.getTaskRequirementTask(
        _taskId,
        extStartRequirementNFTs
      );
      console.log("result:", result);
    } catch (ex) {
      console.log(
        `Get Task Failed - Running Network ${hardhatArguments.network} Error:`,
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
