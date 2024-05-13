import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')

async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

  (async () => {
    const _burnEnabled = await question('What is burn enable [Y/N]?');
    const _burnRatio = await question('What is burn ratio?');
    const EldaPoolManager = new ExtendContract("EldaPoolManager");
    const eldaPoolManager = await EldaPoolManager.contractInstance(true);
    let burnEnabled = true;
    if(String(_burnEnabled) == "Y") {
      burnEnabled = true;
      console.log("true");
    }
    if(String(_burnEnabled) == "N") {
      burnEnabled = false;
      console.log("false");
    }
    console.log(burnEnabled);
    let result = await eldaPoolManager.enableBurn(burnEnabled, Number(_burnRatio));
    result = await result.wait(1);
    if(result.status === 1) {
      console.log("Succesfully");
    }
    rl.close()
  })()
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});