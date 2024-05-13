import { ethers } from "hardhat";
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
    const newName = await question("What is new collection name?");
    const newSymbol = await question("What is new collection symbol?");
    const [owner] = await ethers.getSigners();
    const EldaruneGameCollection = new ExtendContract(
      "EldaruneUtilityCollection"
    );
    const eldaruneGameCollection =
      await EldaruneGameCollection.contractInstance(true, owner);

    try {
      await eldaruneGameCollection.setTokenInformation(
        String(newName),
        String(newSymbol)
      );
      console.log("setTokenInformation successfuly");
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
