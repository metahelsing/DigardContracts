import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')

async function main() {
  
  (async () => {
    
    const EldaPoolManager = new ExtendContract("EldaPoolManager");
    const eldaPoolManager = await EldaPoolManager.contractInstance(true);
    const result = await eldaPoolManager.getLength();
    console.log(result);
  })()
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});