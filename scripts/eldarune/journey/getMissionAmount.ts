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
      const missionRequirementNFTs = [
        {
          tokenAddress: "0x51d54dc3b9ebdD107660055841334893370a1a5b",
          tokenId: "1000",
          amount: "1",
          burnRate: "0",
        },
        {
          tokenAddress: "0x51d54dc3b9ebdD107660055841334893370a1a5b",
          tokenId: "1010",
          amount: "2",
          burnRate: "0",
        },
      ];
      let _missionId = Number(missionId);
      let result = await eldaruneJourneyInstance.getMissionAmount(
        _missionId,
        missionRequirementNFTs
      );
      console.log(result);
    } catch (ex) {
      console.log(
        `Get Amount Failed - Running Network ${hardhatArguments.network} Error:`,
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
