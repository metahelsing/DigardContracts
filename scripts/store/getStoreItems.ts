import { hardhatArguments } from "hardhat";
import { ExtendContract, contractAddress } from "../../utils/contractManager";
const readline = require("readline");
const fs = require("fs").promises;

async function main() {
  const nftWhitelistAddress = await contractAddress("DigardNFTWhitelist");
  const DigardStore = new ExtendContract("DigardStore");
  const digardStore = await DigardStore.contractInstance(true);

  try {
    let _networkName = hardhatArguments.network;
    let storeItems = await fs.readFile(
      `scripts/store/data/storeItems-${_networkName}.json`,
      "utf8"
    );
    storeItems = JSON.parse(storeItems);
    const result = await digardStore.getStoreItems(storeItems);
    console.log(result);
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
