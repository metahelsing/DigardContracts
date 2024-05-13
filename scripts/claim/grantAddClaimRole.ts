import { ethers } from "hardhat";

import { ExtendContract } from "../../utils/contractManager";
const readline = require('readline')


async function main() 
{
      const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

      const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }
  
      (async () => {
        const minterContract = await question('What is grant claim address contract/me?');
        const DigardClaim = new ExtendContract("DigardClaim");
        const digardClaimInstance = await DigardClaim.contractInstance(true);
        const [owner] = await ethers.getSigners();
        //const DigardGameMarketAddress = ContractInfo.getContractAddress("DigardGameMarket");
        let contractAddress = "";
        
        if(String(minterContract) == "me") {
          contractAddress = owner.address;
        }
        else 
          contractAddress = String(minterContract);
       
        try {
              const ADD_CLAIM_ROLE = "0xcd10f5917278f010eb19018e752a65efc6ff4020ff190c1ab2c5b72cf054c2ff";
              await digardClaimInstance.grantRole(ADD_CLAIM_ROLE, contractAddress);
              console.log("addClaimRole successfuly");
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