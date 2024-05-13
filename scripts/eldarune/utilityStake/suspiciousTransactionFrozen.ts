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
    const _subscribeIds = await question("What is subscribeId?");
    const eldaruneUtilityCollectionStaking = new ExtendContract(
      "EldaruneUtilityCollectionStaking"
    );
    const eldaruneUtilityStakingInstance =
      await eldaruneUtilityCollectionStaking.contractInstance(true);
    let subscribeIds = String(_subscribeIds).split(",");
    let result =
      await eldaruneUtilityStakingInstance.suspiciousTransactionFrozen(
        subscribeIds
      );
    result = await result.wait(1);
    if (result.status === 1) {
      console.log("Success");
    } else {
      console.log("Error");
    }
    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
