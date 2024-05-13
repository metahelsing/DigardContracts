import { hardhatArguments } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import { ExtRequirementNft, ExtendedTask } from "./types/taskType";
const fs = require("fs").promises;

async function main() {
  const EldaruneJourney = new ExtendContract("EldaruneJourney");
  const eldaruneJourneyInstance = await EldaruneJourney.contractInstance(true);
  try {
    let _networkName = hardhatArguments.network;
    let requirementNftJSON = await fs.readFile(
      `scripts/eldarune/journey/data/taskList-${_networkName}.json`,
      "utf8"
    );
    requirementNftJSON = JSON.parse(requirementNftJSON);
    let requirementNftList: ExtRequirementNft[] = requirementNftJSON.map(
      (f: ExtendedTask) => {
        return f.requirementNfts;
      }
    );

    let result = await eldaruneJourneyInstance.saveRequirementNfts(
      requirementNftList,
      {
        gasLimit: 12000000,
      }
    );
    result = await result.wait(1);
    if (result.status === 1) {
      console.log(
        `Save Requirement Nft Successfull - Running Network ${hardhatArguments.network}`
      );
    } else {
      console.log(
        `Save Requirement Nft Failed - Running Network ${hardhatArguments.network}`
      );
    }
  } catch (ex) {
    console.log(
      `Save Requirement Nft Failed - Running Network ${hardhatArguments.network} Error:`,
      ex
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
