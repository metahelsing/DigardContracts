// import PlayerClaimItem from "./data/PlayerClaimItem.json";
import PlayerClaimItem from "./data/PlayerClaimItem3.json";
import { ExtendContract } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const DigardClaim = new ExtendContract("DigardClaim");
  const digardClaim = await DigardClaim.contractInstance(true);
  let _PlayerClaimItem = PlayerClaimItem;

  try {
    await digardClaim.addPlayerClaimBatch(_PlayerClaimItem);
    console.log("addPlayerClaimBatch successfuly");
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
