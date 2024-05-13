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
    const eldaruneUtilityCollectionStaking = new ExtendContract(
      "EldaruneUtilityCollectionStaking"
    );
    try {
      const eldaruneUtilityStakingInstance =
        await eldaruneUtilityCollectionStaking.contractInstance(true);
      let result = await eldaruneUtilityStakingInstance.unStakeBulkUtility({
        gasLimit: 12000000,
      });
      result = await result.wait(1);
      if (result.status === 1) {
        let eventFilter = eldaruneUtilityStakingInstance.filters.Unstake();
        if (eventFilter) {
          let events = await eldaruneUtilityStakingInstance.queryFilter(
            eventFilter,
            result.blockNumber,
            result.blockNumber
          );
          if (events) {
            console.log(events);
          }
        }
        console.log(
          "Successfully unStakeBulkUtility ----------------------------------------------------------->"
        );
      } else {
        console.log(
          "Error  unStakeBulkUtility ----------------------------------------------------------->"
        );
      }
    } catch (ex: any) {
      console.log("Error:", ex);
    }

    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
