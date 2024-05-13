import { ethers } from "hardhat";
import {
  ExtendContract,
  contractAddress,
} from "../../../utils/contractManager";

async function main() {
  const [owner, acc1] = await ethers.getSigners();
  const eldaPoolManagerAddress = await contractAddress("EldaPoolManager");
  const digardClaimAddress = await contractAddress("DigardClaim");
  const EldaruneJourney = new ExtendContract("EldaruneJourney");

  await EldaruneJourney.deployUpgradeable([
    eldaPoolManagerAddress,
    digardClaimAddress,
  ]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
