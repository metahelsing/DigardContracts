
import { ExtendContract } from "../../utils/contractManager";
const readline = require('readline')


async function main() 
{
        
        const DigardClaim = new ExtendContract("DigardClaim");
        const digardClaim = await DigardClaim.contractInstance(true);
       
        try {
             
              await digardClaim.changePlayerClaimLockStatus("0xa16f7068BBB2952dECad0427DbA35Db47a918059", false);
              console.log("changePlayerClaimLockStatus successfuly");
             
        } catch (ex){
            console.log(ex);
        }
      
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });


