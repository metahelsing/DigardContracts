import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')

async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

  (async () => {
    const EldaPoolManager = new ExtendContract("EldaPoolManager");
    const eldaPoolManager = await EldaPoolManager.contractInstance(true);
    let result = await eldaPoolManager.distributionBalance();
    result = await result.wait(1);
    if(result.status === 1) {
      console.log("Successfully");
    }
    rl.close()
  })()
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});