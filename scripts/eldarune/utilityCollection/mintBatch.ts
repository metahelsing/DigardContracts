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
    const toAddress = await question("What is to address?");
    const mintAmount = await question("What is Token Amount?");
    const EldaruneUtilityCollection = new ExtendContract(
      "EldaruneUtilityCollection"
    );
    const eldaruneUtilityCollection =
      await EldaruneUtilityCollection.contractInstance(true);

    try {
      const _mintAmount = Number(mintAmount);
      const to = String(toAddress);
      const tokenIds = [1, 2, 3, 4, 5, 6, 7];
      const amounts = [
        _mintAmount,
        _mintAmount,
        _mintAmount,
        _mintAmount,
        _mintAmount,
        _mintAmount,
        _mintAmount,
      ];

      await eldaruneUtilityCollection.mintBatch(to, tokenIds, amounts, "0x");
      console.log("mintItem successfuly");
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
