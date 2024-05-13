import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require("readline");

async function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  (async () => {
    const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox");

    const eldaruneUtilityBoxInstance =
      await eldaruneUtilityBox.contractInstance(true);

    let result = await eldaruneUtilityBoxInstance.burnAll({
      gasLimit: 10000000,
    });
    result = await result.wait(1);
    if (result.status === 1) {
      console.log("success burned All");
    } else console.log("failed burned All");
    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
