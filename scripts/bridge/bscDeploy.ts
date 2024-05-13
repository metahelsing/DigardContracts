import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
const { upgrades } = require("hardhat");
const readline = require('readline');

async function main() {
 
    let BscBridgeContract = new ExtendContract("BSCBridge", false);
    const bscBridgeAddress = await BscBridgeContract.deploy();
    console.log(`BscBridge Contract Address: ${bscBridgeAddress}`);
    
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});