import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import SendBurnedMintList from "./data/sendBurnedMint.json";
const fetch = require('node-fetch');

async function main() {

    const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);
    const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(true);
    
    const addresses = SendBurnedMintList.map((item) => item.Owner).slice(500,SendBurnedMintList.length-1);
    const metaDataUris = SendBurnedMintList.map((item) => item.MetaDataUrl).slice(500,SendBurnedMintList.length-1);
   
    console.log("First:" + addresses[0]);
    console.log("Last:" + addresses[addresses.length-1]);
   
    await eldaruneUtilityBoxInstance.batchMint(addresses, metaDataUris);
   
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});