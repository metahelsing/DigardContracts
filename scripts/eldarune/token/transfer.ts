import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')
let contractAbi:any;


async function main() 
{
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const _toAddress = await question('What is to address?');
        const _transferAmount = await question('What is transfer amount?');
       
        const ELDAToken = new ExtendContract("ELDAToken", false);
        const EldaTokenInterface = await ELDAToken.contractInstance(true);
        try {
            let toAddress = String(_toAddress);
            const transferAmount = ethers.utils.parseEther(String(_transferAmount));
            const result = await EldaTokenInterface.transfer(toAddress, transferAmount);
            if(result) {
                console.log(result.hash);
            }
            
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