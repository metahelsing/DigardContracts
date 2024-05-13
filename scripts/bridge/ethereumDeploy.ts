import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
const { upgrades } = require("hardhat");
const readline = require('readline');

async function main() {
  let Elda721 = new ExtendContract("Elda721", false);
  const elda721ContractAddress = await Elda721.getContractAddress();
  let BSCBridge = new ExtendContract("BSCBridge", false);
  const bSCBridgeAddress = await BSCBridge.getContractAddress("bsctest");
  let EthereumBridgeContract = new ExtendContract("EthereumBridge", false);
  const ethereumBridgeAddress = await EthereumBridgeContract.deploy([elda721ContractAddress, bSCBridgeAddress]);
  console.log(`EthereumBridge Contract Address: ${ethereumBridgeAddress}`);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});