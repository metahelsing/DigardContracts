
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')


async function main() 
{
      const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

      const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }
  
      (async () => {
        
        const _tokenId = await question('What is Token Id?');
        
        const EldaruneUtilityCollection = new ExtendContract("EldaruneUtilityCollection");
        const eldaruneUtilityCollection = await EldaruneUtilityCollection.contractInstance(true);
       
        try {
              
              const tokenId = Number(_tokenId);
              
              const result = await eldaruneUtilityCollection.uri(tokenId);
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