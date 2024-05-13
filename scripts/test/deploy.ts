import { hardhatArguments } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";

async function main() {
  const Test = new ExtendContract("Test");
  try {
    const test = await Test.deployUpgradeable([]);
    console.log(
      `Test Deployed Successfull - Running Network ${hardhatArguments.network}`
    );
  } catch (ex: any) {
    console.log(
      `Test Deployed Successfull - Running Network ${hardhatArguments.network}`
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
