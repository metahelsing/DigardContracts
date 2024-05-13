import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

async function main() {
  const [owner] = await ethers.getSigners();
  const eldarunesTokenBoostCollection = new ExtendContract(
    "EldarunesTokenBoostCollection"
  );
  const eldaruneUtilityBoxInstance =
    await eldarunesTokenBoostCollection.contractInstance(true);

  const tokenURI = await eldaruneUtilityBoxInstance.tokenURI(20001);
  console.log(tokenURI);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
