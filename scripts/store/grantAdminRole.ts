import { ethers } from "hardhat";

import { ExtendContract } from "../../utils/contractManager";
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
    const adminContract = await question("What is grant admin contract/me?");
    const [owner] = await ethers.getSigners();
    const DigardStore = new ExtendContract("DigardStore");
    const digardStoreInstance = await DigardStore.contractInstance(true, owner);

    //const DigardGameMarketAddress = ContractInfo.getContractAddress("DigardGameMarket");
    let contractAddress = "";

    if (String(adminContract) == "me") {
      contractAddress = owner.address;
    } else contractAddress = String(adminContract);

    try {
      const ITEM_SAVE_ROLE = await digardStoreInstance.ITEM_SAVE_ROLE();

      let result = await digardStoreInstance.grantRole(
        ITEM_SAVE_ROLE,
        contractAddress
      );
      result = await result.wait(1);

      if (result.status === 1) {
        console.log("ITEM_SAVE_ROLE successfuly");
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
