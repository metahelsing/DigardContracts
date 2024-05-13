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
    const _tokenId = await question("What is tokenId?");

    const EldarunesTokenBoostCollection = new ExtendContract(
      "EldarunesTokenBoostCollection"
    );
    const eldarunesTokenBoostCollection =
      await EldarunesTokenBoostCollection.contractInstance(true);

    try {
      let tokenId = String(_tokenId);
      let result = await eldarunesTokenBoostCollection.setTokenURI(tokenId);
      result = await result.wait(1);
      if (result.status === 1) {
        console.log(
          `EldarunesTokenBoostCollection setTokenURI Successfull - Running Network ${hardhatArguments.network}`
        );
      } else {
        console.log(
          `EldarunesTokenBoostCollection setTokenURI Status Failed - Running Network ${hardhatArguments.network}`
        );
      }
    } catch (ex) {
      console.log(
        `EldarunesTokenBoostCollection setTokenURI Failed - Running Network ${hardhatArguments.network}`
      );
    }

    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
