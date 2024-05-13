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
    const _workshopItemId = await question("What is workshopItemId");
    const DigardWorkshop = new ExtendContract("DigardWorkshop");
    const DigardWorkshopInterface = await DigardWorkshop.contractInstance(true);

    try {
      let result = await DigardWorkshopInterface.getUpgradeBatch(
        Number(_workshopItemId)
      );
      console.log(result);
      let rtnList = await DigardWorkshopInterface.getEventArgs(
        result,
        "UpgradeResult"
      );
      console.log(rtnList);
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
