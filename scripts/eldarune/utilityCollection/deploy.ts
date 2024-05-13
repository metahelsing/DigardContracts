import { hardhatArguments } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

async function main() {
  const EldaruneUtilityCollection = new ExtendContract(
    "EldaruneUtilityCollection"
  );
  try {
    const eldaruneGameCollection =
      await EldaruneUtilityCollection.deployUpgradeable([]);
    console.log(
      `EldaruneUtilityCollection Deploy Successfull - Running Network ${hardhatArguments.network}`
    );
  } catch (ex) {
    console.log(
      `EldaruneUtilityCollection Deploy Failed - Running Network ${hardhatArguments.network}`
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
