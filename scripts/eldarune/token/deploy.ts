import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
async function main() {
  
  const EldaToken = new ExtendContract("ELDAToken");
  const address = await EldaToken.deploy();
  
  console.log(`Elda Token Contract Address: ${address}`);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});