import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const fs = require("fs").promises;

async function main() {
   
    const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);
    const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(true);
    const list:any = [];
    for(let i = 201; i < 3000; i++) {
        
        const ownerOf = await eldaruneUtilityBoxInstance.ownerOf(i);
        console.log(i + "-" + ownerOf);
        list.push({tokenId: i, ownerOf: ownerOf});
        await fs.writeFile("configs/ownerOf.json", JSON.stringify(list, null, 4));
    }
   
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});