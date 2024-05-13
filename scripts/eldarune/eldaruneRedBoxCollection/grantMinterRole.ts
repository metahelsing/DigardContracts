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
    const EldaruneRedBoxCollection = new ExtendContract(
      "EldaruneRedBoxCollection"
    );
    const eldaruneRedBoxCollection =
      await EldaruneRedBoxCollection.contractInstance(true);
    const [owner] = await ethers.getSigners();

    let contractAddress = "";

    if (String(minterContract) == "me") {
      contractAddress = owner.address;
    } else contractAddress = String(minterContract);

    try {
      const minterRole = await eldaruneRedBoxCollection.MINTER_ROLE();
      const hResult = await eldaruneRedBoxCollection.hasRole(
        minterRole,
        owner.address
      );

      let result = await eldaruneRedBoxCollection.grantRole(
        minterRole,
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
