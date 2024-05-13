import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

async function main() {
  const [owner] = await ethers.getSigners();
  const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox");
  const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(
    true
  );
  const tokenURI = await eldaruneUtilityBoxInstance.balanceOf(209);
  console.log(tokenURI);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
