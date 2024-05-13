
import { ExtendContract } from "../../utils/contractManager";
import PlayerClaimItem from "./data/results/result.json";
const readline = require('readline')


async function main() 
{
        
        const DigardClaim = new ExtendContract("DigardClaim");
        const digardClaim = await DigardClaim.contractInstance(true);
       
        try {
            await digardClaim.updatePlayerNft(PlayerClaimItem[0].playerAddress, PlayerClaimItem[0].claimNftItems);
            console.log("updatePlayerNft successfuly");
             
        } catch (ex){
            console.log(ex);
        }
      
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });


