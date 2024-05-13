import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
const { upgrades } = require("hardhat");
const readline = require('readline');

async function main() {
 
    let BscBridgeContract = new ExtendContract("BSCBridge", false);
    const bscBridgeContractAddress = await BscBridgeContract.getContractAddress("bsctest");
    let EthereumBridgeContract = new ExtendContract("EthereumBridge", false);
     try {
       const ethereumInstance = await EthereumBridgeContract.contractInstance(true);
       await ethereumInstance.setBscBridge(bscBridgeContractAddress);
     } catch (ex: any) {
        console.log(ex);
     }
    
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});