import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

async function main() {
    const [owner] = await ethers.getSigners();
    const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);
    const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(true);
   
    const tokenURI = await eldaruneUtilityBoxInstance.tokenURI(203);
    console.log(tokenURI);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});