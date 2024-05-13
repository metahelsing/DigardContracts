import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";


async function main() {
    
    const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);
    const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(true);
    
    await eldaruneUtilityBoxInstance.burnForUpgrade(210);
   
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});