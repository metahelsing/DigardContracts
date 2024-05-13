// import PlayerClaimItem from "./data/PlayerClaimItem.json";

import { ExtendContract } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const Test = new ExtendContract("Test");
  const test = await Test.contractInstance(true);

  try {
    await test.removeStakingSubscribe(
      "0xDc954ff9819B87946452cb3344995Fbe94A05e48"
    );
    console.log("removeStakingSubscribe successfuly");
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
