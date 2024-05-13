import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')

async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

  (async () => {
    const eldaPoolContractAddress = await question('What is elda pool contract address?');
    const EldaPoolManager = new ExtendContract("EldaPoolManager");
    const eldaPoolManager = await EldaPoolManager.contractInstance(true);
    await eldaPoolManager.addPoolList(String(eldaPoolContractAddress));
    rl.close()
  })()
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});