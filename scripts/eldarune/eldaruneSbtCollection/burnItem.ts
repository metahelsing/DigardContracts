import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import { newLineToArray } from "../../../utils/helpers";
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
    const _toAddress = await question("What is burn address?");
    const _tokenId = await question("What is token id?");
    const _transferAmount = await question("What is burn amount?");
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
      await eldaruneS.burn(
        String(_toAddress),
        Number(_tokenId),
        Number(_transferAmount)
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
