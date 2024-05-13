import { ethers } from "hardhat";

import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')


async function main() 
{
      const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

      const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }
  
      (async () => {
        const minterContract = await question('What is grant claim address contract/me?');
        const AlecSale = new ExtendContract("AlecSale");
        const alecSaleInstance = await AlecSale.contractInstance(true);
        const [owner] = await ethers.getSigners();
        //const DigardGameMarketAddress = ContractInfo.getContractAddress("DigardGameMarket");
        let contractAddress = "";
        
        if(String(minterContract) == "me") {
          contractAddress = owner.address;
        }
        else 
          contractAddress = String(minterContract);
       
        try {
              const ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";
              await alecSaleInstance.grantRole(ADMIN_ROLE, contractAddress);
              console.log("ADMIN_ROLE successfuly");
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