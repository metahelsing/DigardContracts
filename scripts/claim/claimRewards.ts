import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const DigardClaim = new ExtendContract("DigardClaim");
  const [owner, acc1] = await ethers.getSigners();
  const digardClaim = await DigardClaim.contractInstance(true, acc1);

  try {
    const result = await digardClaim.claimRewards();
    let rtnList = await digardClaim.getEventArgs(result, "PlayerNftClaimed");
    console.log(rtnList);
    console.log("claimRewards successfuly");
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
