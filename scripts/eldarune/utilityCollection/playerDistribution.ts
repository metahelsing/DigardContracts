import preSaleDropList from "./data/preSaleDropList.json";
import { ExtendContract } from "../../../utils/contractManager";



async function main() 
{
     
      (async () => {
        
        const EldaruneUtilityCollection = new ExtendContract("EldaruneUtilityCollection");
        const eldaruneUtilityCollection = await EldaruneUtilityCollection.contractInstance(true);
        
        try {
              for(let i = 1; i < preSaleDropList.length; i++) {
                await eldaruneUtilityCollection.mintBatch(preSaleDropList[i].playerAddress, preSaleDropList[i].tokenIds, preSaleDropList[i].amounts, "0x");
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


