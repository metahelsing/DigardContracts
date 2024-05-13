import earlyDragon from "./data/earlyDragon.json";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')


async function main() 
{
      const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

      const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }
  
      (async () => {
        
       
        const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
        const eldaruneGameCollection = await EldaruneGameCollection.contractInstance(true);
       
        try {
              let toAddresses = earlyDragon.map((m)=> { return m.walletAddress});
              let amounts = earlyDragon.map((m)=> { return m.legendary_oAthstone_amount});
              let tokenIds:Array<number> = amounts.map((m)=> {return 4});
             
              await eldaruneGameCollection.mintAddressBatchSingle(toAddresses, tokenIds, amounts, "0x");
              console.log("mintAddressBatchSingle successfuly");
             
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


