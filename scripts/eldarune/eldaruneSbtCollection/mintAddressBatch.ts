import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import { newLineToArray } from "../../../utils/helpers";
import whiteList from "./data/hoeTicket";
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
    const EldaruneS = new ExtendContract("EldaruneS");
    const eldaruneS = await EldaruneS.contractInstance(true);

    try {
      let [owner] = await ethers.getSigners();
      let arr = newLineToArray(whiteList);

      const tokenIds = [14];
      const amounts = [10];
      console.log("arr:", arr);
      let result = await eldaruneS.mintAddressBatch(
        arr,
        tokenIds,
        amounts,
        "0x"
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log("mintAddressBatch successfully");
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
