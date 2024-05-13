import { hardhatArguments } from "hardhat";
import { ExtendContract, contractAddress } from "../../utils/contractManager";
const readline = require("readline");
const fs = require("fs").promises;

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
    const DigardWorkshop = new ExtendContract("DigardWorkshop");
    const DigardWorkshopInterface = await DigardWorkshop.contractInstance(true);
    try {
      let _networkName = hardhatArguments.network;
      let upgradeSchema = await fs.readFile(
        `scripts/workshop/data/results/upgradeSchema-${_networkName}.json`,
        "utf8"
      );
      upgradeSchema = JSON.parse(upgradeSchema);
      console.log("length:", upgradeSchema.length);
      upgradeSchema = upgradeSchema.slice(50, 97);
      console.log(upgradeSchema);
      let result = await DigardWorkshopInterface.saveWorkshopItem(
        upgradeSchema,
        { gasLimit: 30000000 }
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log("Success");
      } else {
        console.log("Error");
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
