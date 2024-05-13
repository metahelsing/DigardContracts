
import { ExtendContract } from "../../utils/contractManager";
const readline = require('readline')


async function main() 
{
       
        const DigardClaim = new ExtendContract("DigardClaim");
        const digardClaim = await DigardClaim.contractInstance(true);
       
        try {
             
              const playerAddressList = await digardClaim.getPlayerAddressNftContractIndex(0, false);
              console.log(playerAddressList);
             
        } catch (ex){
            console.log(ex);
        }
      
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });


