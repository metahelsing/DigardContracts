import { ExtendContract } from "../../../utils/contractManager";
import {EldaruneUtilityBoxFixture} from "./data/eldaruneUtilityBoxData";

async function main() {
  //bla
    const {getMintProgram} = EldaruneUtilityBoxFixture([]);
    const EldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);
    const eldaruneUtilityBox = await EldaruneUtilityBox.contractInstance(true);
    try {
      const mintProgram = await getMintProgram();
      console.log(mintProgram.merkleRoot);
      await eldaruneUtilityBox.setMerkleRoot(mintProgram.merkleRoot);
    } catch (ex: any){
      console.log("err setMerkleRoot " + ex.message);
    }
    
    
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});