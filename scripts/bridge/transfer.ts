import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
const { upgrades } = require("hardhat");
const readline = require('readline');

async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

  (async () => {
    const tokenId = await question('What is to tokenId?');
   
    let EthereumBridgeContract = new ExtendContract("EthereumBridge", false);
    try {
      const ethereumInstance = await EthereumBridgeContract.contractInstance(true);
      const result = await ethereumInstance.transfer();
      console.log(result);
    } catch (ex: any) {
      console.log(ex);
    }
    rl.close()
  })()

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});