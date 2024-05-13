import { ethers } from "hardhat";
import {
  ExtendContract,
  contractAddress,
} from "../../../utils/contractManager";

async function main() {
  const [owner, acc1] = await ethers.getSigners();
  const eldaruneChest = new ExtendContract("EldaruneChest");
  await eldaruneChest.deployUpgradeable([], acc1);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
