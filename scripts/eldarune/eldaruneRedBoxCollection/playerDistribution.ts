import preSaleDropList from "./data/preSaleDropList.json";
import { ExtendContract } from "../../../utils/contractManager";



async function main() 
{
     
      (async () => {
        
        const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
        const eldaruneGameCollection = await EldaruneGameCollection.contractInstance(true);
        
        try {
              for(let i = 1; i < preSaleDropList.length; i++) {
                await eldaruneGameCollection.mintBatch(preSaleDropList[i].playerAddress, preSaleDropList[i].tokenIds, preSaleDropList[i].amounts, "0x");
                console.log(i + " minted");
              }
             
             
        } catch (ex){
            console.log(ex);
        }
        
    })()
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });


