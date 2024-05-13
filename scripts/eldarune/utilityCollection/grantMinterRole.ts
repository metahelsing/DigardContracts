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
    const minterContract = await question("What is minter contract/me?");
    const [owner, acc1] = await ethers.getSigners();
    const EldaruneUtilityCollection = new ExtendContract(
      "EldaruneUtilityCollection"
    );
    const eldaruneUtilityCollection =
      await EldaruneUtilityCollection.contractInstance(true, acc1);

    //const DigardGameMarketAddress = ContractInfo.getContractAddress("DigardGameMarket");
    let contractAddress = "";

    if (String(minterContract) == "me") {
      contractAddress = owner.address;
    } else contractAddress = String(minterContract);

    try {
      const MINTER_ROLE = await eldaruneUtilityCollection.MINTER_ROLE();
      let result = await eldaruneUtilityCollection.hasRole(
        MINTER_ROLE,
        owner.address
      );
      console.log("MINTER_ROLE:" + result);
      const minter_ROLE = await eldaruneUtilityCollection.MINTER_ROLE();
      result = await eldaruneUtilityCollection.grantRole(
        minter_ROLE,
        contractAddress
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log("addMinterRole successfuly");
      } else {
        console.log("addMinterRole failed");
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
