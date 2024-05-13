import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
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
    const [owner, account1] = await ethers.getSigners();
    const _toAddress = await question("What is to address?");
    const _tokenId = await question("What is tokenIds?");
    const _amount = await question("What is amount?");
    const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
    const eldaruneGameCollection =
      await EldaruneGameCollection.contractInstance(true, owner);

    try {
      const to = String(_toAddress);
      const tokenId = String(_tokenId);
      const amounts = String(_amount);

      await eldaruneGameCollection.safeTransferFrom(
        owner.address,
        to,
        tokenId,
        amounts,
        "0x"
      );
      console.log("transfer successfuly");
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