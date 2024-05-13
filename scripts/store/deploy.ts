import { hardhatArguments } from "hardhat";
import { ExtendContract, contractAddress } from "../../utils/contractManager";

async function main() {
  let eldaTokenAddress = await contractAddress("ELDAToken");
  const DigardStore = new ExtendContract("DigardStore");

  try {
    if (eldaTokenAddress == null) {
      eldaTokenAddress = "0x0000000000000000000000000000000000000000";
    }
    const digardStoreAddress = await DigardStore.deployUpgradeable([
      eldaTokenAddress,
    ]);
    console.log(
      `DigardStore Deployed Successfull - Running Network ${hardhatArguments.network} - Deployed Address: ${digardStoreAddress}`
    );
  } catch (ex: any) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
