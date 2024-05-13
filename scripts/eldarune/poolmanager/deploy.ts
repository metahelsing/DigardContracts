import { hardhatArguments } from "hardhat";
import { ExtendContract, contractAddress } from "../../../utils/contractManager";
const readline = require('readline')
const fs = require("fs").promises;

async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

  (async () => {
    
    
    const PoolManager = new ExtendContract("EldaPoolManager");
    const eldaTokenContractAddress = await contractAddress("ELDAToken");
    let _networkName = hardhatArguments.network;
    let poolList = await fs.readFile(`scripts/eldarune/poolmanager/data/poolList-${_networkName}.json`, 'utf8');
    poolList = JSON.parse(poolList);
    try {
      const poolManager = await PoolManager.deployUpgradeable([eldaTokenContractAddress, poolList]);
      console.log(`EldaPoolManager Deploy Successfull - Running Network ${hardhatArguments.network} - Deployed Address: ${poolManager}`)
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