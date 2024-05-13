import { ethers, hardhatArguments } from "hardhat";
import {
  ExtendContract,
  contractAddress,
} from "../../../utils/contractManager";

async function main() {
  const eldaPoolManagerAddress = await contractAddress("EldaPoolManager");
  const EldaruneJourney = new ExtendContract("EldaruneJourney");
  const EldaruneJourneyInterface = await EldaruneJourney.contractInstance(true);
  try {
    let result = await EldaruneJourneyInterface.saveGameTokenPoolAddress(
      eldaPoolManagerAddress
    );
    result = await result.wait(1);
    if (result.status === 1) {
      console.log(
        `Save Game Token Pool Address Successfull - Running Network ${hardhatArguments.network}`
      );
    } else {
    }
  } catch (ex: any) {}
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
