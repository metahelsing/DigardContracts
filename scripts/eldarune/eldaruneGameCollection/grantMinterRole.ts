import { ethers } from "hardhat";

import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')


async function main() 
{
      const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

      const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }
  
      (async () => {
        const minterContract = await question('What is minter contract/me?');
        const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
        const eldaruneSeason1Instance = await EldaruneGameCollection.contractInstance(true);
        const [owner] = await ethers.getSigners();
        //const DigardGameMarketAddress = ContractInfo.getContractAddress("DigardGameMarket");
        let contractAddress = "";
        const DigardClaim = new ExtendContract("DigardClaim");
        const digardClaimContractAddress = await DigardClaim.getContractAddress();
        if(String(minterContract) == "me") {
          contractAddress = owner.address;
        }
        else 
          contractAddress = String(minterContract);
       
        try {
              const minter_role = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
              await eldaruneSeason1Instance.grantRole(minter_role, contractAddress);
              console.log("addMinterRole successfuly");
        } catch (ex){
            console.log(ex);
        }
        rl.close()
    })()
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });