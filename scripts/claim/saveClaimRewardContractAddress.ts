import { ExtendContract, contractAddress } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const ELDAToken = new ExtendContract("ELDAToken");
  let eldaTokenAddress = await ELDAToken.getContractAddress();
  const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
  let eldaruneGameCollectionAddress =
    await EldaruneGameCollection.getContractAddress();
  let alecCollectionAddress = await contractAddress("EldaruneS");
  const DigardClaim = new ExtendContract("DigardClaim");
  const digardClaim = await DigardClaim.contractInstance(true);

  try {
    let result = await digardClaim.saveClaimRewardContractAddress(
      eldaTokenAddress,
      [eldaruneGameCollectionAddress, alecCollectionAddress]
    );
    result = await result.wait(1);
    if (result.status === 1) {
      console.log("saveClaimRewardContractAddress successfuly");
    } else {
      console.log("saveClaimRewardContractAddress failed");
    }
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
