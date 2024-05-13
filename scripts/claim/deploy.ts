import { ExtendContract, contractAddress } from "../../utils/contractManager";

async function main() {
  
  let eldaTokenAddress = await contractAddress("ELDAToken");
  let eldaruneGameCollectionAddress = await contractAddress("EldaruneGameCollection");
  const DigardClaim = new ExtendContract("DigardClaim");
  const digardClaim = await DigardClaim.deployUpgradeable([eldaTokenAddress, [eldaruneGameCollectionAddress]]);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});