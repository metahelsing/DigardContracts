
import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')


async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

  (async () => {
    const _tokenId = await question('What is tokenId?');
    const EldaruneChest = new ExtendContract("EldaruneChest");
    const [owner, account1, account2, account3, account4, account5, account6, account7] = await ethers.getSigners();
    const eldaruneChest = await EldaruneChest.contractInstance(true, account1);
    const provider = ethers.provider;
    try {
      
      let result = await eldaruneChest.getChest(String(_tokenId));
      console.log(result);

    } catch (ex) {
      console.log(ex);
    }
    rl.close()
  })()
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


