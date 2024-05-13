import { hardhatArguments } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import {
  ExtRequirementNft,
  ExtRequirementToken,
  ExtendedTask,
} from "./types/taskType";
const fs = require("fs").promises;

async function main() {
  const EldaruneJourney = new ExtendContract("EldaruneJourney");
  const eldaruneJourneyInstance = await EldaruneJourney.contractInstance(true);
  try {
    let _networkName = hardhatArguments.network;
    let requirementTokenJSON = await fs.readFile(
      `scripts/eldarune/journey/data/taskList-${_networkName}.json`,
      "utf8"
    );
    requirementTokenJSON = JSON.parse(requirementTokenJSON);
    let requirementTokenList: ExtRequirementToken[] = requirementTokenJSON.map(
      (f: ExtendedTask) => {
        return f.requirementTokens;
      }
    );

    let result = await eldaruneJourneyInstance.saveRequirementTokens(
      requirementTokenList,
      {
        gasLimit: 12000000,
      }
    );
    result = await result.wait(1);
    if (result.status === 1) {
      console.log(
        `Save Requirement Token Successfull - Running Network ${hardhatArguments.network}`
      );
    } else {
      console.log(
        `Save Requirement Token Failed - Running Network ${hardhatArguments.network}`
      );
    }
  } catch (ex) {
    console.log(
      `Save Requirement Token Failed - Running Network ${hardhatArguments.network} Error:`,
      ex
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
