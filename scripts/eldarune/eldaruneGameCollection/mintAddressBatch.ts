import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import { newLineToArray } from "../../../utils/helpers";
import whiteList from "./data/mirage/airdropList2";
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
    const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
    const eldaruneGameCollection =
      await EldaruneGameCollection.contractInstance(true);

    try {
      let [owner] = await ethers.getSigners();
      let arr = newLineToArray(whiteList);

      const tokenIds = [8];
      const amounts = [1];

      let result = await eldaruneGameCollection.mintAddressBatch(
        arr,
        tokenIds,
        amounts,
        "0x",
        {
          gasLimit: 4000000,
        }
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log("whiteList: whiteList21 - mintAddressBatch successfully");
      } else {
        console.log("err");
      }
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
