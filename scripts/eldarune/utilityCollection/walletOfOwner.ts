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
    const _walletAddress = await question("What is Wallet Address?");

    const EldaruneUtilityCollection = new ExtendContract(
      "EldaruneUtilityCollection"
    );
    const eldaruneUtilityCollection =
      await EldaruneUtilityCollection.contractInstance(true);

    try {
      const walletAddress = String(_walletAddress);

      const result = await eldaruneUtilityCollection.walletOfOwner(
        walletAddress
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
