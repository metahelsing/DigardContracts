
import { ExtendContract } from "../../utils/contractManager";
import PlayerClaimItem from "./data/results/result.json";
const readline = require('readline')


async function main() 
{
        
        const DigardClaim = new ExtendContract("DigardClaim");
        const digardClaim = await DigardClaim.contractInstance(true);
       
        try {
             for(let i = 0; i < PlayerClaimItem.length; i++) {
                  
             }
              await digardClaim.clearPlayerNft("0xe8d2d8da13cd8269b15831aad39a72c6e4dbf3f8", [{"nftContractIndex": 0, "tokenId": 5, "amount": 1, "deactive": false}]);
              console.log("clearPlayerNft successfuly");
             
        } catch (ex){
            console.log(ex);
        }
      
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });


