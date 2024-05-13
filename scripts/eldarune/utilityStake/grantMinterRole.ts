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
    const [owner, acc1] = await ethers.getSigners();
    const minterContract = await question("What is minter contract/me?");
    const EldaruneUtilityCollectionStaking = new ExtendContract(
      "EldaruneUtilityCollectionStaking"
    );
    const eldaruneUtilityCollectionStakingInstance =
      await EldaruneUtilityCollectionStaking.contractInstance(true, acc1);

    let contractAddress = "";

    if (String(minterContract) == "me") {
      contractAddress = owner.address;
    } else contractAddress = String(minterContract);

    try {
      const pROGRAM_MODIFIER_ROLE =
        await eldaruneUtilityCollectionStakingInstance.PROGRAM_MODIFIER_ROLE();

      const hResult = await eldaruneUtilityCollectionStakingInstance.hasRole(
        pROGRAM_MODIFIER_ROLE,
        owner.address
      );
      console.log("hResult:", hResult);
      let result = await eldaruneUtilityCollectionStakingInstance.grantRole(
        pROGRAM_MODIFIER_ROLE,
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
