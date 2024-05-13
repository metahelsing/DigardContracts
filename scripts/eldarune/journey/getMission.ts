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
    const missionId = await question("What is missionId?");
    const [owner, acc1] = await ethers.getSigners();
    const EldaruneJourney = new ExtendContract("EldaruneJourney");
    const eldaruneJourneyInstance = await EldaruneJourney.contractInstance(
      true
    );
    try {
      let _missionId = Number(missionId);
      let result = await eldaruneJourneyInstance.getMission(_missionId);
      console.log(result);
    } catch (ex) {
      console.log(
        `Start Mission Failed - Running Network ${hardhatArguments.network} Error:`,
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
