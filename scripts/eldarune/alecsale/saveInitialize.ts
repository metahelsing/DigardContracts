import { ethers } from "hardhat";
import whiteList from "./data/whiteList.json";
import { ExtendContract } from "../../../utils/contractManager";


async function main() {
    const [owner] = await ethers.getSigners();
    
    const eldaToken = new ExtendContract("ELDAToken");
    const eldaTokenContractAddress = await eldaToken.getContractAddress();
    const eldaruneS = new ExtendContract("EldaruneS");
    const eldaruneSContractAddress = await eldaruneS.getContractAddress();
    const alecSale = new ExtendContract("AlecSale");
    const alecSaleInstance = await alecSale.contractInstance(true);
    
    await alecSaleInstance.saveInitialize(eldaTokenContractAddress, eldaruneSContractAddress,whiteList, "0", "1", true, false);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});