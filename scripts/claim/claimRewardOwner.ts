import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const question = (prompt: string) => {
    return new Promise((resolve, reject) => {
      rl.question(prompt, resolve);
    });
  };

  (async () => {
    const playerAddress = await question("What is playerAddress?");
    const DigardClaim = new ExtendContract("DigardClaim");
    const [owner, acc1] = await ethers.getSigners();
    const digardClaim = await DigardClaim.contractInstance(true, owner);

    try {
      const result = await digardClaim.claimRewardOwner(String(playerAddress));
      let rtnList = await digardClaim.getEventArgs(result, "PlayerNftClaimed");
      console.log(rtnList);
      console.log("claimRewards successfuly");
    } catch (ex) {
      console.log(ex);
    }
    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
