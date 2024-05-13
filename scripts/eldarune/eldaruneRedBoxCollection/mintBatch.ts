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
    const _toAddress = await question("What is to address?");
    const _tokenIds = await question("What is token ids?");
    const _mintAmount = await question("What is token amount?");
    const EldaruneRedBoxCollection = new ExtendContract(
      "EldaruneRedBoxCollection"
    );
    const eldaruneRedBoxCollection =
      await EldaruneRedBoxCollection.contractInstance(true);

    try {
      const to = String(_toAddress);
      const tokenIds = String(_tokenIds).split(",");
      const amounts = String(_mintAmount).split(",");
      await eldaruneRedBoxCollection.mintBatch(to, tokenIds, amounts, "0x");
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
