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
    const _wallet = await question("What is Pool Owner?");
    const DigardWorkshop = new ExtendContract("DigardWorkshop");
    const DigardWorkshopInterface = await DigardWorkshop.contractInstance(true);

    try {
      let result = await DigardWorkshopInterface.setWorkshopPoolOwner(
        String(_wallet)
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log("Successfully");
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
