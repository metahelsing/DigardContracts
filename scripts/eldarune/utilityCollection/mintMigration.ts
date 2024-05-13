import { ExtendContract } from "../../../utils/contractManager";
import lastMigrationList from "./data/results/lastMigrationList.json";
const readline = require("readline");

async function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  (async () => {
    const EldaruneUtilityCollection = new ExtendContract(
      "EldaruneUtilityCollection"
    );
    const eldaruneUtilityCollection =
      await EldaruneUtilityCollection.contractInstance(true);

    try {
      let _lastMigrationList = lastMigrationList;

      for (let i = 2067; i < _lastMigrationList.length; i++) {
        let to = _lastMigrationList[i].owner;
        let tokenIds = _lastMigrationList[i].tokenIds.filter(
          (f: number, index: number) => _lastMigrationList[i].amounts[index] > 0
        );
        let amounts = _lastMigrationList[i].amounts.filter(
          (f: number) => f > 0
        );
        console.log("tokenIds:", tokenIds, "amounts:", amounts);
        let result = await eldaruneUtilityCollection.mintBatch(
          to,
          tokenIds,
          amounts,
          "0x"
        );
        result = await result.wait(1);
        if (result.status === 1) {
          console.log(
            `${i}/${_lastMigrationList.length} ${to} - Success sended`
          );
        } else
          console.log(
            `${i}/${_lastMigrationList.length} ${to} - Failed sended`
          );
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
