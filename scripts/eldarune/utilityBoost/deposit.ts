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
    const _rarityId = await question("What is rarity id?");
    const _amount = await question("What is amount?");

    const EldarunesTokenBoostCollection = new ExtendContract(
      "EldarunesTokenBoostCollection"
    );
    const eldarunesTokenBoostCollection =
      await EldarunesTokenBoostCollection.contractInstance(true);

    try {
      let result = await eldarunesTokenBoostCollection.deposit(
        Number(_rarityId),
        Number(_amount)
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log(
          `EldarunesTokenBoostCollection Deposit Successfull - Running Network ${hardhatArguments.network}`
        );
      } else {
        console.log(
          `EldarunesTokenBoostCollection Deposit Status Failed - Running Network ${hardhatArguments.network}`
        );
      }
    } catch (ex) {
      console.log(
        `EldarunesTokenBoostCollection Deposit Failed - Running Network ${hardhatArguments.network}`
      );
    }

    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
