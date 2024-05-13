import { ExtendContract, contractAddress } from "../../utils/contractManager";
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
    const _whitelistAddress = await question("What is whitelist address?");
    const _tokenAddress = await question("What is tokenAddress?");
    const _tokenId = await question("What is token id?");
    const DigardNFTWhitelist = new ExtendContract("DigardNFTWhitelist");
    const DigardNFTWhitelistInterface =
      await DigardNFTWhitelist.contractInstance(true);

    try {
      const result = await DigardNFTWhitelistInterface.getWhitelist(
        String(_whitelistAddress),
        String(_tokenAddress),
        Number(_tokenId)
      );
      console.log(result);
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
