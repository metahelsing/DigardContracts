import { ExtendContract, contractAddress } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const nftWhitelistAddress = await contractAddress("DigardNFTWhitelist");
  const DigardStore = new ExtendContract("DigardStore");
  const digardStore = await DigardStore.contractInstance(true);

  try {
    await digardStore.saveDigardNftWhitelist(nftWhitelistAddress);
    console.log("saveDigardNftWhitelist successfuly");
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
