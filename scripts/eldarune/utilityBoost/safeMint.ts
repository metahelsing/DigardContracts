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
    const _rarityId = await question("What is rarityId?");
    const _to = await question("What is to address?");
    const EldarunesTokenBoostCollection = new ExtendContract(
      "EldarunesTokenBoostCollection"
    );
    const eldarunesTokenBoostCollection =
      await EldarunesTokenBoostCollection.contractInstance(true);

    try {
      let rarityId = String(_rarityId);
      let toAddress = String(_to);
      let result = await eldarunesTokenBoostCollection.safeMint(
        rarityId,
        toAddress
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log(
          `EldarunesTokenBoostCollection safeMint Successfull - Running Network ${hardhatArguments.network}`
        );
      } else {
        console.log(
          `EldarunesTokenBoostCollection safeMint Status Failed - Running Network ${hardhatArguments.network}`
        );
      }
    } catch (ex) {
      console.log(
        `EldarunesTokenBoostCollection safeMint Failed - Running Network ${hardhatArguments.network}`
      );
    }

    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
