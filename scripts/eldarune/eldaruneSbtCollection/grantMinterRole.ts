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
    const EldaruneS = new ExtendContract("EldaruneS");
    const eldaruneSInstance = await EldaruneS.contractInstance(true, owner);

    let contractAddress = "";

    if (String(minterContract) == "me") {
      contractAddress = owner.address;
    } else contractAddress = String(minterContract);

    try {
      const minterRole = await eldaruneSInstance.MINTER_ROLE();
      const hResult = await eldaruneSInstance.hasRole(
        minterRole,
        owner.address
      );
      console.log("hResult:", hResult);
      let result = await eldaruneSInstance.grantRole(
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
