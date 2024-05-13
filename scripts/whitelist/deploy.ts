import { ethers, hardhatArguments } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";

async function main() {
  const [owner, acc1] = await ethers.getSigners();
  const DigardNFTWhitelist = new ExtendContract("DigardNFTWhitelist");
  try {
    let tx = await DigardNFTWhitelist.deployUpgradeable([], owner);
    console.log(
      `DigardNFTWhitelist Deployed Successfull - Running Network ${hardhatArguments.network}`
    );
  } catch (ex: any) {
    console.log(
      `DigardNFTWhitelist Deployed Error - Running Network ${hardhatArguments.network}`
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
