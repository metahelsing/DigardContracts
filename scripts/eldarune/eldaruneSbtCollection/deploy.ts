import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

async function main() {
  
  const EldaruneS = new ExtendContract("EldaruneS");
  const eldaruneS = await EldaruneS.deployUpgradeable([]);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});