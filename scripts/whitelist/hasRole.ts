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
    const address = await question("What is balance of Wallet Address?");

    const [
      owner,
      account1,
      account2,
      account3,
      account4,
      account5,
      account6,
      account7,
    ] = await ethers.getSigners();

    const DigardNFTWhitelist = new ExtendContract("DigardNFTWhitelist");
    const digardNFTWhitelistInstance =
      await DigardNFTWhitelist.contractInstance(true);

    try {
      const WHITELIST_ADDED_ROLE =
        await digardNFTWhitelistInstance.WHITELIST_ADDED_ROLE();
      const hasRoleResult = await digardNFTWhitelistInstance.hasRole(
        WHITELIST_ADDED_ROLE,
        String(address)
      );
      console.log(hasRoleResult);
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
