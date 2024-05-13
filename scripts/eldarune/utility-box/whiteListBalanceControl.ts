import { ExtendContract } from "../../../utils/contractManager";
import {EldaruneUtilityBoxFixture} from "./data/eldaruneUtilityBoxData";

async function main() {
  
    const {balanceControl} = EldaruneUtilityBoxFixture([]);
    
    try {
      await balanceControl();
      
    } catch (ex: any){
      console.log("err balanceControl " + ex.message);
    }
    
    
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});