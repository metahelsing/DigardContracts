import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import { newLineToArray } from "../../../utils/helpers";
import whiteList from "./data/results/common.json";
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
    const EldaruneUtilityCollection = new ExtendContract(
      "EldaruneUtilityCollection"
    );
    const eldaruneUtilityCollection =
      await EldaruneUtilityCollection.contractInstance(true);

    try {
      let [owner] = await ethers.getSigners();
      //let arr = newLineToArray(whiteList);
      // let toes = whiteList;
      let arr = ["0xA171A83040E7df24446CBc370DebD9e595549F64"];
      const tokenIds = [1, 2, 3, 4, 5, 6, 7];
      const amounts = [1, 1, 1, 1, 1, 1, 1];
      await eldaruneUtilityCollection.mintAddressBatch(
        arr,
        tokenIds,
        amounts,
        "0x"
      );
      console.log("mintAddressBatch successfuly");
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
