
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')


async function main() 
{
      const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

      const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }
  
      (async () => {
        const toAddress = await question('What is to address?');
        const mintTokenId = await question('What is Token Id?');
        const mintAmount = await question('What is Token Amount?');
        const EldaruneSeason1 = new ExtendContract("EldaruneGameCollection");
        const eldaruneSeason1 = await EldaruneSeason1.contractInstance(true);
       
        try {
              const to = String(toAddress);
              const tokenId = Number(mintTokenId);
              const amount = Number(mintAmount);
              await eldaruneSeason1.mint(to, tokenId, amount, "0x");
              console.log("mintItem successfuly");
              const balanceOf = await eldaruneSeason1.balanceOf(to, tokenId);
              console.log("Balance: " + balanceOf);
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