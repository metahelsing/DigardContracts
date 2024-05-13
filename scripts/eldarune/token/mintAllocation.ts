import { ethers } from "hardhat";

import {
  ExtendContract,
  contractAddress,
} from "../../../utils/contractManager";
const readline = require("readline");
let contractAbi: any;

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
    const _mintAmount = await question("What is mint amount?");
    const EldaToken = new ExtendContract("ELDAToken");
    const eldaTokenInstance = await EldaToken.contractInstance(true);

    try {
      const mintAmount = ethers.utils.parseEther(String(_mintAmount));
      await eldaTokenInstance.mintAllocation(mintAmount);
      console.log("mintAllocation successfuly");
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
