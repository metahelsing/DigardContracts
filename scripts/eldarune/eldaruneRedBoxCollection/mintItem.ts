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
    const mintTokenId = await question("What is Token Id?");
    const mintAmount = await question("What is Token Amount?");
    const EldaruneRedBoxCollection = new ExtendContract(
      "EldaruneRedBoxCollection"
    );
    const eldaruneRedBoxCollection =
      await EldaruneRedBoxCollection.contractInstance(true);

    try {
      const to = String(toAddress);
      const tokenId = Number(mintTokenId);
      const amount = Number(mintAmount);
      let result = await eldaruneRedBoxCollection.mint(
        to,
        tokenId,
        amount,
        "0x"
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log("mintItem successfuly");
        const balanceOf = await eldaruneRedBoxCollection.balanceOf(to, tokenId);
        console.log("Balance: " + balanceOf);
      } else {
        console.log("mintItem failed");
      }
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
