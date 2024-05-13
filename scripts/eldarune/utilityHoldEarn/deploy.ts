import { hardhatArguments } from "hardhat";
import {
  ExtendContract,
  contractAddress,
} from "../../../utils/contractManager";

async function main() {
  const EldaruneHoldEarn = new ExtendContract("EldaruneHoldEarn");
  let eldaruneUtilityCollection = await contractAddress(
    "EldaruneUtilityCollection"
  );

  try {
    const eldaruneHoldEarn = await EldaruneHoldEarn.deployUpgradeable([
      eldaruneUtilityCollection,
    ]);
    console.log(
      `EldaruneHoldEarn Deployed Successfull - Running Network ${hardhatArguments.network}`
    );
  } catch (ex: any) {
    console.log(
      `EldaruneHoldEarn Deployed Error - Running Network ${hardhatArguments.network}`
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
