import { ethers, hardhatArguments } from "hardhat";
import {
  ExtendContract,
  contractAddress,
} from "../../../utils/contractManager";

async function main() {
  const [owner] = await ethers.getSigners();

  const EldarunesTokenBoostCollection = new ExtendContract(
    "EldarunesTokenBoostCollection"
  );

  let eldaruneUtilityCollection = await contractAddress(
    "EldaruneUtilityCollection"
  );

  try {
    const eldarunesTokenBoostCollection =
      await EldarunesTokenBoostCollection.deployUpgradeable([
        owner.address,
        owner.address,
        owner.address,
        eldaruneUtilityCollection,
      ]);

    console.log(
      `EldarunesTokenBoostCollection Deploy Successfull - Running Network ${hardhatArguments.network}`
    );
  } catch (ex) {
    console.log(
      `EldarunesTokenBoostCollection Deploy Failed - Running Network ${hardhatArguments.network}`
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
