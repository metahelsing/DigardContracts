import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
const readline = require('readline')


async function main() 
{
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const DigardClaim = new ExtendContract("DigardClaim");
        const digardClaim = await DigardClaim.contractInstance(true);
        const minterContract = await question('What is grant claim address contract/me?');
        let contractAddress = "";
        const [owner] = await ethers.getSigners();
        if(String(minterContract) == "me") {
          contractAddress = owner.address;
        }
        else 
          contractAddress = String(minterContract);
        try {
              const ADD_CLAIM_ROLE = "0xcd10f5917278f010eb19018e752a65efc6ff4020ff190c1ab2c5b72cf054c2ff";
              const result = await digardClaim.hasRole(ADD_CLAIM_ROLE, contractAddress);
              console.log(result);
             
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


