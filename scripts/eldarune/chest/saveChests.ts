import { ethers, hardhatArguments } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import { BigNumber } from "ethers";
const fs = require("fs").promises;

async function main() {
  const EldaruneChest = new ExtendContract("EldaruneChest");
  const eldaruneChest = await EldaruneChest.contractInstance(true);

  try {
    let [owner] = await ethers.getSigners();
    let _networkName = hardhatArguments.network;
    let chests = await fs.readFile(
      `scripts/eldarune/chest/data/saveChest-${_networkName}.json`,
      "utf8"
    );
    chests = JSON.parse(chests);

    let result = await eldaruneChest.saveChests(chests, { gasLimit: 9000000 });
    result = await result.wait(1);
    if (result.status === 1) {
      console.log(
        `Save Chest Successfull - Running Network ${hardhatArguments.network}`
      );
    } else {
      console.log(
        `Save Chest Status Failed - Running Network ${hardhatArguments.network}`
      );
    }
  } catch (ex) {
    console.log(ex);
    console.log(
      `Save Chest Failed - Running Network ${hardhatArguments.network}`
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
