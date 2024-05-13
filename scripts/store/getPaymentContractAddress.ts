import { hardhatArguments } from "hardhat";
import { ExtendContract, contractAddress } from "../../utils/contractManager";
const readline = require("readline");
const fs = require("fs").promises;

async function main() {
  const DigardStore = new ExtendContract("DigardStore");
  const digardStore = await DigardStore.contractInstance(true);

  try {
    const result = await digardStore.getPaymentContractAddress();
    console.log(result);
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
