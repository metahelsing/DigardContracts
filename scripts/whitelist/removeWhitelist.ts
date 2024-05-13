import { hardhatArguments } from "hardhat";
import { ExtendContract, contractAddress } from "../../utils/contractManager";
const readline = require("readline");
const fs = require("fs").promises;

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
    const DigardNFTWhitelist = new ExtendContract("DigardNFTWhitelist");
    const DigardNFTWhitelistInterface =
      await DigardNFTWhitelist.contractInstance(true);
    try {
      let _networkName = hardhatArguments.network;
      let whitelist = await fs.readFile(
        `scripts/whitelist/data/results/remove-whitelist-${_networkName}.json`,
        "utf8"
      );
      whitelist = JSON.parse(whitelist);
      const result = await DigardNFTWhitelistInterface.removeWhitelist(
        whitelist
      );
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
