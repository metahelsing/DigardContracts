import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
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
    const toAddress = await question("What is to address?");
    const [
      owner,
      account1,
      account2,
      account3,
      account4,
      account5,
      account6,
      account7,
    ] = await ethers.getSigners();
    const EldaruneS = new ExtendContract("EldaruneS");
    const eldaruneS = await EldaruneS.contractInstance(true);

    try {
      const to = String(toAddress);
      const tokenIds = [6, 7, 8, 15, 16, 17, 18, 19, 20, 21];
      const amounts = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
      await eldaruneS.mintBatch(to, tokenIds, amounts, "0x");
      console.log("mintItem successfuly");
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
