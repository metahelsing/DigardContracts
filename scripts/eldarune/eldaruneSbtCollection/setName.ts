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

    const [owner] = await ethers.getSigners();
    const EldaruneGameCollection = new ExtendContract("EldaruneS");
    const eldaruneGameCollection =
      await EldaruneGameCollection.contractInstance(true, owner);

    try {
      await eldaruneGameCollection.setName(String(newName));
      console.log("setName successfuly");
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
