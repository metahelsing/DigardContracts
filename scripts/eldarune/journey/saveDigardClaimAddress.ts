import { ethers, hardhatArguments } from "hardhat";
import {
  ExtendContract,
  contractAddress,
} from "../../../utils/contractManager";

async function main() {
  const eldaPoolManagerAddress = await contractAddress("EldaPoolManager");
  const digardClaimAddress = await contractAddress("DigardClaim");
  const EldaruneJourney = new ExtendContract("EldaruneJourney");
  const EldaruneJourneyInterface = await EldaruneJourney.contractInstance(true);
  try {
    let result = await EldaruneJourneyInterface.saveDigardClaimAddress(
      digardClaimAddress
    );
    result = await result.wait(1);
    if (result.status === 1) {
      console.log(
        `Save Digard Claim Successfull - Running Network ${hardhatArguments.network}`
      );
    } else {
    }
  } catch (ex: any) {}
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
