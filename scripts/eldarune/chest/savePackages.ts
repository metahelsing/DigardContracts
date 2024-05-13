import { hardhatArguments } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const fs = require("fs").promises;

async function main() {
  const EldaruneChest = new ExtendContract("EldaruneChest");
  const eldaruneChest = await EldaruneChest.contractInstance(true);

  try {
    let _networkName = hardhatArguments.network;
    let packages = await fs.readFile(
      `scripts/eldarune/chest/data/savePackage-${_networkName}.json`,
      "utf8"
    );
    packages = JSON.parse(packages);
    let result = await eldaruneChest.savePackages(packages, {
      gasLimit: 4000000,
    });
    result = await result.wait(1);
    if (result.status === 1) {
      console.log(
        `Save Package Successfull - Running Network ${hardhatArguments.network}`
      );
    } else {
      console.log(
        `Save Package Failed - Running Network ${hardhatArguments.network}`
      );
    }
  } catch (ex) {
    console.log(ex);
    console.log(
      `Save Package Failed - Running Network ${hardhatArguments.network}`
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
