import { ethers } from "hardhat";

import { ExtendContract } from "../../../utils/contractManager";
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
    const [owner, acc1] = await ethers.getSigners();
    const EldaruneChest = new ExtendContract("EldaruneChest");
    const eldaruneChestInstance = await EldaruneChest.contractInstance(
      true,
      acc1
    );

    //const DigardGameMarketAddress = ContractInfo.getContractAddress("DigardGameMarket");
    let contractAddress = "";

    if (String(adminContract) == "me") {
      contractAddress = owner.address;
    } else contractAddress = String(adminContract);

    try {
      const DEFAULT_ADMIN_ROLE =
        await eldaruneChestInstance.DEFAULT_ADMIN_ROLE();

      let result = await eldaruneChestInstance.grantRole(
        DEFAULT_ADMIN_ROLE,
        contractAddress
      );
      result = await result.wait(1);

      if (result.status === 1) {
        console.log("DEFAULT_ADMIN_ROLE successfuly");
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
