// import PlayerClaimItem from "./data/PlayerClaimItem.json";

import { ExtendContract } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const Test = new ExtendContract("Test");
  const test = await Test.contractInstance(true);
  const stakingInformation = {
    stakingSubscribeId: 3,
    stakingProgramId: 3,
    tokenId: 3,
    amount: 3,
    startTime: 3,
    active: true,
  };

  try {
    await test.saveStakingSubscribe(
      stakingInformation,
      "0xDc954ff9819B87946452cb3344995Fbe94A05e48"
    );
    console.log("saveStakingSubscribe successfuly");
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
