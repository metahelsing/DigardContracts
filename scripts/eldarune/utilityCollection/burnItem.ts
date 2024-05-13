import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

const readline = require("readline");
let contractAbi: any;

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
    const _walletAddress = await question("What is wallet address?");
    const _tokenId = await question("What is token id?");
    const _transferAmount = await question("What is burn amount?");
    const EldaruneUtilityCollection = new ExtendContract(
      "EldaruneUtilityCollection"
    );
    const eldaruneUtilityCollection =
      await EldaruneUtilityCollection.contractInstance(true);

    try {
      await eldaruneUtilityCollection.burnOwned(
        String(_walletAddress),
        Number(_tokenId),
        Number(_transferAmount),
        { gasLimit: 4000000 }
      );
      console.log("burn successfuly");
    } catch (ex) {
      console.log(ex);
    }
    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
