import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

async function main() {
    const [owner] = await ethers.getSigners();
    const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);
    const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(true);
    await eldaruneUtilityBoxInstance.mintTest(500);
    // for(var i = 200; i < 220; i++) {
      
    //   console.log(i);
    // }
    
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});