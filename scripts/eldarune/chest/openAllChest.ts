
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')


async function main() 
{
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const _tokenId = await question('What is tokenId?');
        const EldaruneChest = new ExtendContract("EldaruneChest");
        const eldaruneChest = await EldaruneChest.contractInstance(true);
       
        try {
             
              let tx = await eldaruneChest.openAllChest(String(_tokenId));
              tx = await tx.wait();
              if(tx.status===1){
                console.log("openAllChest successfuly");
                console.log(tx);
              }
              else console.log("openAllChest error");
             
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


