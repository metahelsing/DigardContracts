import { ethers, hardhatArguments } from "hardhat";
import {
  ExtendContract,
  contractAddress,
} from "../../../utils/contractManager";

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
    const EldarunesTokenBoostCollection = new ExtendContract(
      "EldarunesTokenBoostCollection"
    );
    const eldarunesTokenBoostCollection =
      await EldarunesTokenBoostCollection.contractInstance(true);

    try {
      let result = await eldarunesTokenBoostCollection.setTokenCapabilities();
      result = await result.wait(1);
      if (result.status === 1) {
        console.log(
          `EldarunesTokenBoostCollection setTokenCapabilities Successfull - Running Network ${hardhatArguments.network}`
        );
      } else {
        console.log(
          `EldarunesTokenBoostCollection setTokenCapabilities Status Failed - Running Network ${hardhatArguments.network}`
        );
      }
    } catch (ex) {
      console.log(
        `EldarunesTokenBoostCollection setTokenCapabilities Failed - Running Network ${hardhatArguments.network}`
      );
    }

    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
