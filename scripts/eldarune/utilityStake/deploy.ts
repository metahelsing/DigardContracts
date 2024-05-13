import { hardhatArguments } from "hardhat";
import {
  ExtendContract,
  contractAddress,
} from "../../../utils/contractManager";

async function main() {
  const EldaruneUtilityCollectionStaking = new ExtendContract(
    "EldaruneUtilityCollectionStaking"
  );
  let eldaruneUtilityCollection = await contractAddress(
    "EldaruneUtilityCollection"
  );
  let digardClaim = await contractAddress("DigardClaim");
  try {
    const eldaruneUtilityCollectionStaking =
      await EldaruneUtilityCollectionStaking.deployUpgradeable([
        eldaruneUtilityCollection,
        digardClaim,
      ]);
    console.log(
      `EldaruneUtilityCollectionStaking Deployed Successfull - Running Network ${hardhatArguments.network}`
    );
  } catch (ex: any) {
    console.log(
      `EldaruneUtilityCollectionStaking Deployed Error - Running Network ${hardhatArguments.network}`
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
