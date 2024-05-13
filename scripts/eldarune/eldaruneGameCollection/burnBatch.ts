import earlyDragon from "./data/earlyDragon.json";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')


async function main() 
{
      const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

      const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }
  
      (async () => {
        const toAddress = await question('What is to address?');
        const mintAmount = await question('What is Token Amount?');
        const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
        const eldaruneSeason1 = await EldaruneGameCollection.contractInstance(true);
       
        try {
          let toAddresses = earlyDragon.map((m)=> { return m.walletAddress});
          let amounts = earlyDragon.map((m)=> { return m.walletAddress});
          let tokenIds:Array<number> = amounts.map((m)=> {return 4});

              await eldaruneSeason1.burnAddressBatchSingle(toAddresses, tokenIds, amounts);
              console.log("burnAddressBatchSingle successfuly");
             
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
