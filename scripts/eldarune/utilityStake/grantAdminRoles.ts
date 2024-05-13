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
      const PAUSER_ROLE =
        await eldaruneUtilityCollectionStakingInstance.PAUSER_ROLE();
      const UPGRADER_ROLE =
        await eldaruneUtilityCollectionStakingInstance.UPGRADER_ROLE();

      const pauserResult =
        await eldaruneUtilityCollectionStakingInstance.hasRole(
          PAUSER_ROLE,
          owner.address
        );
      const upgraderResult =
        await eldaruneUtilityCollectionStakingInstance.hasRole(
          UPGRADER_ROLE,
          owner.address
        );
      console.log("PAUSER_ROLE:", pauserResult);
      console.log("UPGRADER_ROLE:", upgraderResult);
      let result = await eldaruneUtilityCollectionStakingInstance.grantRole(
        PAUSER_ROLE,
        contractAddress
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log("PAUSER_ROLE granted.");
      } else {
        console.log("PAUSER_ROLE failed.");
      }

      result = await eldaruneUtilityCollectionStakingInstance.grantRole(
        UPGRADER_ROLE,
        contractAddress
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log("UPGRADER_ROLE granted.");
      } else {
        console.log("UPGRADER_ROLE failed.");
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
