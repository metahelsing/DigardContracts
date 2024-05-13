import { hardhatArguments } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
const fs = require("fs").promises;

async function main() {
  const DigardStore = new ExtendContract("DigardStore");
  const digardStore = await DigardStore.contractInstance(true);

  try {
    let _networkName = hardhatArguments.network;
    let storeItems = await fs.readFile(
      `scripts/store/data/storeItems-${_networkName}.json`,
      "utf8"
    );
    storeItems = JSON.parse(storeItems);

    let result = await digardStore.saveStoreItem(storeItems, {
      gasLimit: 4000000,
    });
    result = await result.wait(1);

    if (result.status === 1) {
      console.log("saveStoreItems successfuly");
    } else {
      console.log("saveStoreItems error");
    }
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
