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
    const [owner, acc1, acc2] = await ethers.getSigners();
    const EldarunesTokenBoostCollection = new ExtendContract(
      "EldarunesTokenBoostCollection"
    );
    const eldarunesTokenBoostCollection =
      await EldarunesTokenBoostCollection.contractInstance(true, acc2);

    try {
      let result = await eldarunesTokenBoostCollection.getTokenIds([16]);
      console.log(result);
    } catch (ex) {
      console.log(ex);
      console.log(
        `EldarunesTokenBoostCollection getTokenIds Failed - Running Network ${hardhatArguments.network}`
      );
    }

    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
