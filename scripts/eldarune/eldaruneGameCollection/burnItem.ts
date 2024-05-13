import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

const readline = require('readline')
let contractAbi:any;


async function main() 
{
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const [owner,acc1] = await ethers.getSigners();
        const _walletAddress = await question('What is wallet address?');
        const _tokenId = await question('What is token id?');
        const _transferAmount = await question('What is burn amount?');
        const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
        const eldaruneGameCollection = await EldaruneGameCollection.contractInstance(true, acc1);
        
        try {
            await eldaruneGameCollection.burn(String(_walletAddress), Number(_tokenId), Number(_transferAmount));
            console.log("burn successfuly");
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